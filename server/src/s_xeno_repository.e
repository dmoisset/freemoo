class S_XENO_REPOSITORY

inherit
    XENO_REPOSITORY
        redefine race_type, add end
    STORABLE
        redefine dependents end
    SERVER_ACCESS
    SERVICE
        redefine subscription_message end

feature -- Hashing

    hash_code: INTEGER is
    do
        Result := to_pointer.hash_code
    end

feature

    subscription_message (service_id: STRING): STRING is
        -- Send message describing known races.  For now, just send everything
        -- to everybody!
    local
        s: SERIALIZER2
        race_it: ITERATOR[S_RACE]
    do
        create s.make
        s.add_integer (races.count)
        from
            race_it := races.get_new_iterator_on_items
        until
            race_it.is_off
        loop
            s.add_integer(race_it.item.id)
            race_it.next
        end
        Result := s.serialized_form
    end

    update_clients is
    do
        -- Check to avoid updates on initialization
        if registry /= Void then
            send_message ("xeno_repository", subscription_message ("xeno_repository"))
        end
    end

feature -- Operations

    add(race: like race_type) is
    local
        service_id: STRING
    do
        Precursor(race)
        service_id := "race" + race.id.to_string
        if not server.has(service_id) then
            server.register(race, service_id)
        end
        update_clients
    end

feature {NONE} -- Anchors

    race_type: S_RACE

feature {STORAGE} -- Saving

    get_class: STRING is "XENO_REPOSITORY"

    fields: ITERATOR[TUPLE[STRING, ANY]] is
    local
        a: ARRAY[TUPLE[STRING, ANY]]
    do
        create a.make(1, 0)
        add_to_fields(a, "race", races.get_new_iterator_on_items)
        Result := a.get_new_iterator
    end

    dependents: ITERATOR[STORABLE] is
    local
        a: ARRAY[STORABLE]
    do
        create a.make(1, 0)
        add_dependents_to(a, races.get_new_iterator_on_items)
        Result := a.get_new_iterator
    end

feature {STORAGE} -- Operations - Retrieving

    set_primary_keys (elems: ITERATOR [TUPLE [STRING, ANY]]) is
    do
    end

    make_from_storage (elems: ITERATOR [TUPLE [STRING, ANY]]) is
    local
        race: like race_type
    do
        from
        until elems.is_off loop
            if elems.item.first.has_prefix("race") then
                race ?= elems.item.second
                check not races.has(race.id) end
                add (race)
            else
                print ("Bad child '" + elems.item.first + "' inside 'XENO_REPOSITORY' tag%N")
            end
            elems.next
        end
    end

end -- class S_XENO_REPOSITORY
