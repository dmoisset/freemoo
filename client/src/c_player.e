class C_PLAYER
    -- Should subscribe after galaxy

inherit
    PLAYER
    rename make as player_make end
    SUBSCRIBER
    CLIENT

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

    unserialize_from (serial: STRING) is
        -- Update from `serial'. Modifies `serial' removing the
        -- text processed
    local
        s: SERIALIZER
        ir: reference INTEGER
        br: reference BOOLEAN
    do
        s.unserialize ("isiib", serial)
        ir ?= s.unserialized_form @ 1; set_id (ir)
        name ?= s.unserialized_form @ 2
        ir ?= s.unserialized_form @ 3; set_state (ir)
        ir ?= s.unserialized_form @ 4; set_color (ir)
        br ?= s.unserialized_form @ 5; connected := br

        serial.remove_first (s.used_serial_count)
    end

feature {SERVICE_PROVIDER} -- Subscriber callback

    on_message (msg: STRING; provider: SERVICE_PROVIDER; service: STRING) is
        -- Action when `msg' arrives from `provider''s `service'
    local
        s: SERIALIZER
        ir: reference INTEGER
        i: INTEGER
        newmsg: STRING
        star: C_STAR
    do
        newmsg := clone (msg)
        s.unserialize ("i", newmsg)
        ir ?= s.unserialized_form @ 1
        newmsg.remove_first (s.used_serial_count)
        from
            i := ir
            knows_star.clear
        until i = 0 loop
            s.unserialize ("i", newmsg)
            ir ?= s.unserialized_form @ 1
            newmsg.remove_first (s.used_serial_count)
            if server.galaxy.stars.has (ir) then
                star ?= server.galaxy.stars @ ir
                    check star /= Void end
                knows_star.add (star)
                star.subscribe (server, "star"+star.id.to_string)
            else
                print ("Warning: star not found!%N")
            end
            i := i - 1
        end
    end

feature -- Access

    connected: BOOLEAN
        -- Player has a connection to the server

end -- class C_PLAYER