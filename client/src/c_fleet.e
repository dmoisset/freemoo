class C_FLEET
    -- Fleet, client's view
    -- This model can have incomplete information.

inherit
    FLEET
    redefine make end
    MODEL
    SUBSCRIBER
    CLIENT

creation
    make

feature {NONE} -- Creation

    make is
    do
        Precursor
        make_model
    end

    on_message (msg: STRING; provider: SERVICE_PROVIDER; service: STRING) is
        -- Action when `msg' arrives from `provider''s service `service'
        -- Only `service' expected is "fleet"+id
    local
        i: INTEGER
        s: UNSERIALIZER
        it: ITERATOR[PLAYER]
        shipcount: INTEGER
        sh: SHIP
    do
        !!s.start (msg)
        s.get_integer
        from it := server.player_list.get_new_iterator until
            it.item.id = s.last_integer
        loop
            it.next
        end
        owner := it.item
        set_owner (owner)
        s.get_integer
        set_eta (s.last_integer)
        s.get_integer
        if eta = 0 then
            if (is_in_orbit) then
                leave_orbit
            end
            i := s.last_integer
            enter_orbit (server.galaxy.stars @ i);
            if not (server.galaxy.stars @ i).fleets.has(id) then
                (server.galaxy.stars @ i).fleets.add(Current, id);
                (server.galaxy.stars @ i).notify_views
            end
        else
            if is_in_orbit then leave_orbit end
            set_destination (server.galaxy.stars @ s.last_integer)
        end
        s.get_integer
        shipcount := s.last_integer
        unserialize_from (s) -- Position
--        print("Received <<" + owner.id.to_string + ", " + eta.to_string + ", " + orbit_center.id.to_string + ", " + s.last_integer.to_string + ">>%N")
        ships.clear
        from until shipcount = 0 loop
            !!sh.make(owner)
            s.get_integer
            sh.set_id (s.last_integer)
            s.get_integer
            sh.set_size (s.last_integer)
            s.get_integer
            sh.set_picture(s.last_integer)
            shipcount := shipcount - 1
            add_ship (sh)
        end
        notify_views
    end

end -- class C_FLEET
