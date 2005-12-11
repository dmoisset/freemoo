class S_PLAYER_LIST

inherit
    PLAYER_LIST [S_PLAYER]
    redefine
        add, set_player_state
    end
    STORABLE
    redefine
        dependents
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


feature -- Saving

    hash_code: INTEGER is
    do
        Result := Current.to_pointer.hash_code
    end

feature {STORAGE} -- Saving

    get_class: STRING is "PLAYER_LIST"

    fields: ITERATOR[TUPLE[STRING, ANY]] is
    local
        a: ARRAY[TUPLE[STRING, ANY]]
    do
        create a.make (1,0)
        add_to_fields(a, "player", items.get_new_iterator_on_items)
        Result := a.get_new_iterator
    end

    dependents: ITERATOR[STORABLE] is
    do
        Result := items.get_new_iterator_on_items
    end

feature {STORAGE} -- Retrieving

    set_primary_keys (elems: ITERATOR [TUPLE [STRING, ANY]]) is
    do
    end

    make_from_storage (elems: ITERATOR [TUPLE [STRING, ANY]]) is
    local
        player: S_PLAYER
    do
        from
            items.clear
        until elems.is_off loop
            if elems.item.first.has_prefix("player") then
                player ?= elems.item.second
                items.add(player, player.name)
            end
            elems.next
        end
    end

end -- class S_PLAYER_LIST
