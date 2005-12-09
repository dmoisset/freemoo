class S_COLONY

inherit
    COLONY
    redefine
        owner, location, shipyard, ship_factory,
        new_turn, set_producing, set_task
    end
    STORABLE
    rename
        hash_code as id
    redefine
        dependents, primary_keys
    end
    SERVICE
        redefine subscription_message end
    SERVER_ACCESS

creation make

feature -- Service related

    update_clients is
    do
        -- Check to avoid updates on initialization
        if registry /= Void then
            send_message ("colony" + id.to_string, subscription_message ("colony" + id.to_string))
        end
    end

    subscription_message (service_id: STRING): STRING is
    local
        s: SERIALIZER2
        i: ITERATOR[POPULATION_UNIT]
    do
        !!s.make
        s.add_integer(producing - product_min)
        s.add_integer(population)
        s.add_integer(populators.count)
        from i := populators.get_new_iterator_on_items until i.is_off loop
            i.item.serialize_on(s)
            i.next
        end
        Result := s.serialized_form
    end

feature -- Redefined features

    location: S_PLANET

    owner: S_PLAYER

    shipyard: S_SHIP

    ship_factory: S_SHIP_FACTORY

    new_turn is
    do
        Precursor
        if shipyard /= Void then
            server.register(shipyard, "ship" + shipyard.id.to_string)
        end
        update_clients
    end

    set_producing(newproducing: INTEGER) is
    do
        Precursor(newproducing)
        update_clients
    end

    set_task(pops: HASHED_SET[POPULATION_UNIT]; task: INTEGER) is
    do
        Precursor(pops, task)
        update_clients
    end

feature {STORAGE} -- Saving

    get_class: STRING is "COLONY"

    fields: ITERATOR[TUPLE[STRING, ANY]] is
    do
        Result := (<<["producing", (producing-product_min).box],
                     ["owner", owner],
                     ["location", location]
                     >>).get_new_iterator
    end

    primary_keys: ITERATOR[TUPLE[STRING, ANY]] is
    do
        Result := (<<["id", id.box] >>).get_new_iterator
    end

    dependents: ITERATOR[STORABLE] is
    do
        Result := (<<owner, location>>).get_new_iterator
    end

feature {STORAGE} -- Retrieving

    set_primary_keys (elems: ITERATOR [TUPLE [STRING, ANY]]) is
    local
        i: REFERENCE [INTEGER]
    do
        from
        until elems.is_off loop
            if elems.item.first.is_equal("id") then
                i ?= elems.item.second
                id := i.item
            end
            elems.next
        end
    end

    make_from_storage (elems: ITERATOR [TUPLE [STRING, ANY]]) is
    local
        i: REFERENCE [INTEGER]
    do
        from
        until elems.is_off loop
            if elems.item.first.is_equal("producing") then
                i ?= elems.item.second
                producing := i.item + product_min
            elseif elems.item.first.is_equal("owner") then
                owner ?= elems.item.second
            elseif elems.item.first.is_equal("location") then
                location ?= elems.item.second
            end
            elems.next
        end
    end

end -- class S_COLONY
