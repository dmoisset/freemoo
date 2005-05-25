class C_PLAYER
    -- Should subscribe after galaxy

inherit
    PLAYER
    rename make as player_make end
    SUBSCRIBER
    undefine copy, is_equal end
    CLIENT
    undefine copy, is_equal end

creation
    make

feature {NONE} -- Creation

    make (new_name: STRING) is
    do
        make_unique_id
        name := clone (new_name)
        player_make
    ensure
        name.is_equal (new_name)
    end

feature -- Operations

    unserialize_from (s: UNSERIALIZER) is
        -- Update from `s'.
    do
        s.get_integer; set_state (s.last_integer)
        s.get_integer; set_color (s.last_integer)
        s.get_boolean; connected := s.last_boolean
    end

feature {SERVICE_PROVIDER} -- Subscriber callback

    on_message (msg: STRING; provider: SERVICE_PROVIDER; service: STRING) is
        -- Action when `msg' arrives from `provider''s `service'
    local
        s: UNSERIALIZER
        i: INTEGER
        star: C_STAR
        old_list: like knows_star
    do
        !!s.start (msg)
        s.get_integer
        from
            i := s.last_integer
            old_list := clone (knows_star)
            knows_star.clear
        until i = 0 loop
            s.get_integer
            if server.galaxy.has_star (s.last_integer) then
                star := server.galaxy.star_with_id (s.last_integer)
                knows_star.add (star)
                if not old_list.has (star) then 
                    -- We do the above check to avoid network overhead
                    -- Not doing iit implies we re-suscribe to the star service for
                    -- ALL stars
                    star.subscribe (server, "star"+star.id.to_string)
                else
                    old_list.remove (star)
                end
            else
                print ("Warning: star not found!%N")
            end
            i := i - 1
        end
            -- Assumption: A player never forgets about a star:
            check old_list.is_empty end
    end

feature -- Access

    connected: BOOLEAN
        -- Player has a connection to the server

end -- class C_PLAYER
