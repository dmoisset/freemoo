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
        if is_in_orbit then
-- Check if necessary to do a notify_views on orbit_center
			leave_orbit
		end
        if s.last_integer /= -1 then
            i := s.last_integer
                check orbit_center = Void or orbit_center = server.galaxy.star_with_id (i) end
            if orbit_center = Void then
                enter_orbit (server.galaxy.star_with_id (i)) ;
--FIXME: notification should be done when fleet is added
                (server.galaxy.star_with_id (i)).notify_views
            end
        end
        s.get_integer
        if s.last_integer /= -1  then
            set_destination (server.galaxy.star_with_id (s.last_integer))
        end
        s.get_integer
        shipcount := s.last_integer
        unserialize_from (s) -- Position
        ships.clear
        if shipcount = 0 then server.galaxy.remove_fleet (Current) end
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
