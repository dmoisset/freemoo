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
            send_message ("player" + id.to_string, subscription_message ("player" + id.to_string))
        end
    end

    serialize_on (s: SERIALIZER2) is
    do
        s.add_tuple (<<id, name, state, color, connection/=Void>>)
    end

feature -- Access

    password: STRING
        -- Player password

    connection: SPP_SERVER_CONNECTION
        -- Conection to client

feature -- Redefined features

    subscription_message (service_id: STRING): STRING is
    local
        serv_id: STRING
        s: SERIALIZER2
        i: ITERATOR [STAR]
    do
        !!s.make
        -- Validate service_id
        if service_id.has_prefix("player") then
            !!serv_id.copy(service_id)
            serv_id.remove_prefix("player")
            if serv_id.is_integer and then serv_id.to_integer = id then
                s.add_integer (knows_star.count)
                i := knows_star.get_new_iterator
                from i.start until i.is_off loop
                    s.add_integer (i.item.id)
                    i.next
                end
            end
        end
        Result := s.serialized_form
    end

    add_to_known_list (star: STAR) is
    do
        Precursor (star)
        update_clients
    end

end -- class S_PLAYER