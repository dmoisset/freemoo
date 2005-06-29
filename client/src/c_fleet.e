class C_FLEET
    -- Fleet, client's view
    -- This model can have incomplete information.

inherit
    FLEET
    redefine make, ship_type, orbit_center, owner end
    SUBSCRIBER
    CLIENT

creation
    make

feature {NONE} -- Creation

    make is
    do
        Precursor
        create changed.make
    end

    on_message (msg: STRING; provider: SERVICE_PROVIDER; service: STRING) is
        -- Action when `msg' arrives from `provider''s service `service'
        -- Only `service' expected is "fleet"+id
    local
        i, ship_id, shtype: INTEGER
        s: UNSERIALIZER
        shipcount: INTEGER
        sh: C_SHIP
        old_ships: like ships
        factory: C_SHIP_FACTORY
    do
        !!s.start (msg)
        s.get_integer
        set_owner (server.player_list.item_id (s.last_integer))
        s.get_integer
        set_eta (s.last_integer)
        s.get_integer
        if is_in_orbit then
-- Check if necessary to do a notify_views on orbit_center
            leave_orbit
        end
        if s.last_integer /= -1 then
            i := s.last_integer
                check orbit_center = Void or orbit_center = server.galaxy.star_with_id (i) end
            if orbit_center = Void then
                enter_orbit (server.galaxy.star_with_id (i))
            end
        end
        s.get_integer
        if s.last_integer /= -1  then
            set_destination (server.galaxy.star_with_id (s.last_integer))
        end
        s.get_integer
        shipcount := s.last_integer
        unserialize_from (s) -- Position
        old_ships := clone(ships)
        ships.clear
        if shipcount = 0 then server.galaxy.remove_fleet (Current) end
        create factory
        from until shipcount = 0 loop
            s.get_integer
            ship_id := s.last_integer
            s.get_integer
            shtype := s.last_integer + factory.ship_type_min
            if has_ship(ship_id) then
                sh := old_ships.at(ship_id)
            else
                factory.create_by_type(shtype, owner)
                sh := factory.last_ship
                sh.set_id(ship_id)
                server.subscribe(sh, "ship" + sh.id.to_string)
            end
            sh.unserialize_from(s)
            add_ship(sh)
            shipcount := shipcount - 1
        end
        changed.emit (Current)
    end

feature -- Redefined anchors

    ship_type: C_SHIP

    orbit_center: C_STAR

    owner: C_PLAYER

feature -- Signals

    changed: SIGNAL_1 [C_FLEET]

end -- class C_FLEET
