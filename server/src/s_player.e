class S_PLAYER

inherit
    PLAYER
    rename
        make as player_make
    redefine
        add_to_known_list
    end
    SERVICE
    redefine
        subscription_message
    end

creation
    make

feature {NONE} -- Creation

    make (new_name, new_password: STRING) is
    do
        name := clone (new_name)
        password := clone (new_password)
        player_make
        make_unique_id
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

    update_clients is
    do
        -- Check to avoid updates on initialization
        if registry /= Void then
            send_message ("player"+id.to_string, subscription_message (""))
        end
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
        s.serialize ("isiib", <<id, name, state, color, connection/=Void>>)
        Result := s.serialized_form
    ensure
        -- name is the first item serialized
    end

feature -- Redefined features

    subscription_message (service_id: STRING): STRING is
    local
        s: SERIALIZER
        i: ITERATOR [STAR]
    do
        !!Result.make (0)
        s.serialize ("i", <<knows_star.count>>)
        Result.append (s.serialized_form)
        i := knows_star.get_new_iterator
        from i.start until i.is_off loop
            s.serialize ("i", <<i.item.id>>)
            Result.append (s.serialized_form)
            i.next
        end
    end

    add_to_known_list (star: STAR) is
    do
        Precursor (star)
        update_clients
    end

end -- class S_PLAYER