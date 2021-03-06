class C_GALAXY
    -- Galactic map (client view)
    -- This model can have incomplete information, because server only sends
    -- what the player at the client should know.

inherit
    CLIENT
    GALAXY
        redefine last_star, last_fleet, make, add_fleet, ship_type end
    SUBSCRIBER

creation
    make

feature {NONE} -- Creation

    make is
    do
        Precursor
        create fleets_change.make
        create star_change.make
        create map_change.make
    end

feature {SERVICE_PROVIDER} -- Subscriber callback

    on_message (msg: STRING; provider: SERVICE_PROVIDER; service: STRING) is
        -- Action whe `msg' arrives from `provider''s `service'
        -- Regenerates everything from scratch.  There must be a better way...
        -- Also, depend on stars not moving around in the array.
    do
        if service.is_equal("galaxy") then
            unpack_galaxy_message(msg)
        elseif service.has_suffix(":scanner") then
            unpack_scanner_message(msg)
        elseif service.has_suffix(":new_fleets") then
            unpack_new_fleets_message(msg)
        elseif service.has_suffix(":enemy_colonies") then
            unpack_enemy_colonies_message(msg)
        else
            check unexpected_message: False end
        end
    end

    unpack_galaxy_message (msg: STRING) is
    local
        new_stars: like stars
        id, count: INTEGER
        s: UNSERIALIZER
        star: like last_star
    do
        !!s.start (msg)
        limit.unserialize_from (s)
        s.get_integer
        count := s.last_integer
        !!new_stars.make
        from until count = 0 loop
            s.get_integer
            id := s.last_integer
            if stars.has(id) then
                star ?= stars @ id
            else
                !!star.make_defaults
                star.changed.connect (agent star_changed)
                star.set_id (id)
            end
            s.get_integer
            star.set_kind(s.last_integer + star.kind_min)
            s.get_integer
            star.set_size(s.last_integer + star.stsize_min)
            star.unserialize_from (s)
            new_stars.add(star, id)
            count := count - 1
        end
        stars := new_stars
        map_change.emit (Current)
    end

    unpack_enemy_colonies_message (msg: STRING) is
    local
        count: INTEGER
        orbit: INTEGER
        s: UNSERIALIZER
        colony: C_COLONY
        star: C_STAR
        planet: C_PLANET
        owner: PLAYER
        star_it: ITERATOR[C_STAR]
        planet_it: ITERATOR[C_PLANET]
    do
        !!s.start (msg)
        -- Remove all _enemy_ colonies
        from star_it := stars.get_new_iterator_on_items until
            star_it.is_off
        loop
            from planet_it := star_it.item.get_new_iterator_on_planets until
                planet_it.is_off
            loop
                if planet_it.item /= Void and then planet_it.item.colony /= Void and then planet_it.item.colony.owner /= server.player then
                    planet_it.item.set_colony(Void)
                end
                planet_it.next
            end
            star_it.next
        end
        s.get_integer
        count := s.last_integer
        from until count = 0 loop
            s.get_integer
            star := stars @ (s.last_integer)
            s.get_integer
            orbit := s.last_integer
            planet := star.planet_at(orbit)
            if planet = Void then
                -- Probably we're just arriving at star.  Complete 
                -- information for the planet shall arrive shortly.
                star.set_planet(create{C_PLANET}.make_standard (star), orbit)
                planet := star.planet_at(orbit)
            end
            s.get_integer
            owner := server.player_list.item_id (s.last_integer)
            create colony.make(planet, owner)
            count := count - 1
        end
    end


    unpack_scanner_message (msg: STRING) is
    local
        new_fleets: like fleets
        count, shipcount: INTEGER
        s: UNSERIALIZER
        owner: C_PLAYER
        fleet: C_FLEET
        ship: C_SHIP
        factory: C_SHIP_FACTORY
        fleet_it: ITERATOR[like last_fleet]
    do
        !!s.start (msg)
        s.get_integer
        count := s.last_integer
        !!new_fleets.make
        -- Add in our own fleets first
        from fleet_it := fleets.get_new_iterator_on_items
        until fleet_it.is_off
        loop
            if fleet_it.item.owner = server.player then
                new_fleets.add(fleet_it.item, fleet_it.item.id)
            end
            fleet_it.next
        end

        -- Then add in alien fleets we've scanned
        from until count = 0 loop
            !!fleet.make
            s.get_integer
            owner := server.player_list.item_id (s.last_integer)
            fleet.set_owner (owner)
            s.get_integer
            fleet.set_eta (s.last_integer)
            s.get_integer
            if fleet.eta = 0 then
                fleet.enter_orbit (stars @ s.last_integer)
            else
                fleet.set_destination (stars @ s.last_integer)
            end
            s.get_integer -- Ship count
            shipcount := s.last_integer

            fleet.unserialize_from (s)
            if new_fleets.has (fleet.id) then
                std_error.put_string ("Warning: scanned fleet "+fleet.id.out+" twice%N")
            end
            new_fleets.put(fleet, fleet.id)

            !!factory
            from until shipcount = 0 loop
                s.get_integer
                factory.create_by_type(s.last_integer + factory.ship_type_min,
                                       fleet.owner)
                ship := factory.last_ship
                ship.unserialize_from(s)
                shipcount := shipcount - 1
                fleet.add_ship(ship)
            end
            count := count - 1
        end
        fleets := new_fleets
        fleets_change.emit (Current)
    end

    unpack_new_fleets_message (msg: STRING) is
    local
        s: UNSERIALIZER
        i: INTEGER
        fleet: like last_fleet
    do
        !!s.start (msg)
        s.get_integer
        from i := s.last_integer until i = 0 loop
            s.get_integer
            !!fleet.make
            fleet.changed.connect (agent fleet_changed)
            fleet.set_owner(server.player)
            fleet.set_id (s.last_integer)
            add_fleet(fleet)
            i := i - 1
        end
    end

feature -- Redefined features

    last_star: C_STAR

    last_fleet: C_FLEET

    ship_type: C_SHIP

    add_fleet(new_fleet: like last_fleet) is
    do
        fleets.add(new_fleet, new_fleet.id)
        server.subscribe(new_fleet, "fleet" + new_fleet.id.to_string)
    end

feature -- Signals

    fleets_change: SIGNAL_1 [C_GALAXY]

    star_change: SIGNAL_1 [C_STAR]

    map_change: SIGNAL_1 [C_GALAXY]

feature -- Redefined features

    fleet_changed (fleet: C_FLEET) is
    do
        fleets_change.emit (Current)
    end

    star_changed (star: C_STAR) is
    do
        star_change.emit (star)
    end


end -- class C_GALAXY
