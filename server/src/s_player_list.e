class S_PLAYER_LIST

inherit
    PLAYER_LIST [S_PLAYER]
    redefine
        add, set_player_state
    end
    SERVICE
    redefine
        subscription_message
    end

creation
    make

feature -- Redefined features

    subscription_message (service_id: STRING): STRING is
    local
        s: SERIALIZER2
        i: ITERATOR [S_PLAYER]
    do
        !!s.make
        s.add_integer (items.count)
        from
            i := items.get_new_iterator_on_items
        until i.is_off loop
            i.item.serialize_on (s)
            i.next
        end
        Result := s.serialized_form
    end

    add (item: S_PLAYER) is
    do
        Precursor (item)
        update_clients
    end

    set_player_state (p: PLAYER; new_state: INTEGER) is
    do
        Precursor (p, new_state)
        update_clients
    end

feature -- Access

    id: STRING is "players_list"

feature -- Operations

    update_clients is
    do
        send_message (id, subscription_message (id))
    end

end -- class S_PLAYER_LIST