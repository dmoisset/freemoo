class C_PLAYER

inherit
    PLAYER
    rename make as player_make end

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

feature -- Access

    connected: BOOLEAN
        -- Player has a connection to the server

end -- class C_PLAYER