class S_PLAYER

inherit
    PLAYER
    rename make as player_make end

creation
    make

feature {NONE} -- Creation

    make (new_name, new_password: STRING) is
    do
        name := clone (new_name)
        password := clone (new_password)
        player_make
    ensure
        name.is_equal (new_name)
        password.is_equal (new_password)
        state = st_setup
    end

feature -- Operations

    set_connection (new_connection: SPP_SERVER_CONNECTION) is
    do
        connection := new_connection
    ensure
        connection = new_connection
    end

feature -- Access

    password: STRING
        -- Player password

    connection: SPP_SERVER_CONNECTION
        -- Conection to client

    serial_form: STRING is
    local
        s: SERIALIZER
    do
        s.serialize ("siib", <<name, state, color_id, connection/=Void>>)
        Result := s.serialized_form
    ensure
        -- name is the first item serialized
    end

end -- class S_PLAYER