class C_GALAXY
    -- Galactic map (client view)
    -- This model can have incomplete information, because server only sends
    -- what the player at the client should know.

inherit
    CLIENT
    GALAXY
        redefine make, stars, set_stars, fleets, add_fleet end
    MODEL
        redefine notify_views end
    VIEW [C_STAR]
        rename on_model_change as on_star_change end
    VIEW [C_FLEET]
        rename on_model_change as on_fleet_change end
    SUBSCRIBER

creation
    make

feature {NONE} -- Creation

    make is
    do
        Precursor
        make_model
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
        else
            check unexpected_message: False end
        end
    end

    unpack_galaxy_message (msg: STRING) is
    local
        new_stars: DICTIONARY[C_STAR, INTEGER]
        id, count: INTEGER
        s: UNSERIALIZER
        star: C_STAR
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
                star.add_view (Current)
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
        set_stars (new_stars)
        notify_views
    end

    unpack_scanner_message (msg: STRING) is
    local
        new_fleets: DICTIONARY[C_FLEET, INTEGER]
        count, shipcount: INTEGER
        s: UNSERIALIZER
        owner: PLAYER
        fleet: C_FLEET
        ship: SHIP
        it: ITERATOR[PLAYER]
        star_it: ITERATOR[STAR]
		fleet_it: ITERATOR[C_FLEET]
    do
        !!s.start (msg)
        from star_it := stars.get_new_iterator_on_items
        until star_it.is_off
        loop
            star_it.item.fleets.clear
            star_it.next
        end
        s.get_integer
        count := s.last_integer
        !!new_fleets.make
		from fleet_it := fleets.get_new_iterator_on_items
		until fleet_it.is_off
		loop
			if fleet_it.item.owner = server.player then
				new_fleets.add(fleet_it.item, fleet_it.item.id)
-- FIXME: more abstraction breach
				if fleet_it.item.orbit_center /= Void and then fleet_it.item.destination = Void then
					fleet_it.item.orbit_center.fleets.add (fleet_it.item, fleet_it.item.id)
				end
			end
			fleet_it.next
		end

        from until count = 0 loop
            !!fleet.make
            s.get_integer
            from it := server.player_list.get_new_iterator until
                it.item.id = s.last_integer
            loop
                it.next
            end
            owner := it.item
            fleet.set_owner (owner)
            s.get_integer
            fleet.set_eta (s.last_integer)
            s.get_integer
            if fleet.eta = 0 then
                fleet.enter_orbit (stars @ s.last_integer);
-- FIXME: notify should be done by star when fleet is added
                (stars @ s.last_integer).notify_views
            else
                fleet.set_destination (stars @ s.last_integer)
            end
            s.get_integer -- Ship count
            shipcount := s.last_integer
            fleet.unserialize_from (s)
            new_fleets.add(fleet, fleet.id)
            from until shipcount = 0 loop
                !!ship.make (fleet.owner)
                s.get_integer
                ship.set_size (s.last_integer)
                s.get_integer
                ship.set_picture (s.last_integer)
                shipcount := shipcount - 1
                fleet.add_ship(ship)
            end
            count := count - 1
        end
        fleets := new_fleets
        notify_views
    end

    unpack_new_fleets_message (msg: STRING) is
    local
        s: UNSERIALIZER
        i: INTEGER
        fleet: C_FLEET
    do
        !!s.start (msg)
        s.get_integer
        from i := s.last_integer until i = 0 loop
            s.get_integer
            !!fleet.make
            fleet.add_view(Current)
            fleet.set_owner(server.player)
            fleet.set_id (s.last_integer)
            add_fleet(fleet)
            i := i - 1
        end
    end

feature -- Redefined features

	
	
    stars: DICTIONARY [C_STAR, INTEGER]

    fleets: DICTIONARY [C_FLEET, INTEGER]

    set_stars (starlist: DICTIONARY [C_STAR, INTEGER]) is
    do
        stars := starlist
        changed_starlist := True
        notify_views
    end

    add_fleet(new_fleet: C_FLEET) is
    do
        fleets.add(new_fleet, new_fleet.id)
        server.subscribe(new_fleet, "fleet" + new_fleet.id.to_string)
    end

feature -- Redefined features

    on_star_change is
        -- Stars changed
    do
        changed_stardata := True
        notify_views
    end

    on_fleet_change is
        -- Stars changed
    do
        changed_stardata := True
        notify_views
    end

feature -- Notification

    changed_starlist: BOOLEAN

    changed_stardata: BOOLEAN

    notify_views is
    do
        Precursor
        changed_starlist := False
        changed_stardata := False
    end

end -- class C_GALAXY
