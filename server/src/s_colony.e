class S_COLONY

inherit
    COLONY
    redefine
        owner, location, shipyard, ship_factory,
        new_turn, set_producing, set_task, populator_type
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

    populator_type: S_POPULATION_UNIT

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
    local
        a: ARRAY[TUPLE[STRING, ANY]]
    do
        create a.make(1, 0)
        a.add_last(["producing", (producing-product_min).box])
        a.add_last(["owner", owner])
        a.add_last(["location", location])
        a.add_last(["population", population.box])
        a.add_last(["preclimate", preclimate.box])
        a.add_last(["pregrav", pregrav.box])
        a.add_last(["extra_popgrowth", extra_population_growth.box])
        a.add_last(["extra_maxpop", extra_max_population.box])
        add_to_fields(a, "populator", populators.get_new_iterator_on_items)
        -- Still missing constructions!
        Result := a.get_new_iterator
    end

    primary_keys: ITERATOR[TUPLE[STRING, ANY]] is
    do
        Result := (<<["id", id.box] >>).get_new_iterator
    end

    dependents: ITERATOR[STORABLE] is
    local
        a: ARRAY[STORABLE]
    do
        create a.make(1, 0)
        a.add_last(owner)
        a.add_last(location)
        add_dependents_to(a, populators.get_new_iterator_on_items)
        Result := a.get_new_iterator
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
        p: S_POPULATION_UNIT
    do
        from
            populators.clear
        until elems.is_off loop
            if elems.item.first.is_equal("producing") then
                i ?= elems.item.second
                producing := i.item + product_min
            elseif elems.item.first.is_equal("owner") then
                owner ?= elems.item.second
            elseif elems.item.first.is_equal("location") then
                location ?= elems.item.second
            elseif elems.item.first.is_equal("population") then
                i ?= elems.item.second
                population := i.item
            elseif elems.item.first.is_equal("preclimate") then
                i ?= elems.item.second
                preclimate := i.item
            elseif elems.item.first.is_equal("pregrav") then
                i ?= elems.item.second
                pregrav := i.item
            elseif elems.item.first.is_equal("extra_popgrowth") then
                i ?= elems.item.second
                extra_population_growth := i.item
            elseif elems.item.first.is_equal("extra_maxpop") then
                i ?= elems.item.second
                extra_max_population := i.item
            elseif elems.item.first.has_prefix("populator") then
                p ?= elems.item.second
                populators.add (p, p.id)
            else
                print ("Bad element inside 'colony' tag: " + elems.item.first + "%N")
            end
            elems.next
        end
    end

end -- class S_COLONY
