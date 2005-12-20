class S_COLONY

inherit
    COLONY
    redefine
        owner, location, shipyard, ship_factory,
        new_turn, set_producing, set_task, populator_type, starship_design
    end
    STORABLE
    rename
        hash_code as id
    redefine
        dependents, primary_keys, copy, is_equal
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
        pop_it: ITERATOR[POPULATION_UNIT]
        const_it: ITERATOR[CONSTRUCTION]
    do
        !!s.make
        s.add_integer(producing - product_min)
        if producing > product_max then
            starship_design.design.serialize_completely_on(s)
        end
        s.add_integer(produced)
        s.add_boolean(has_bought)
        s.add_integer(population)
        s.add_integer(populators.count)
        s.add_integer(constructions.count)
        from
            pop_it := populators.get_new_iterator_on_items
        until
            pop_it.is_off
        loop
            pop_it.item.serialize_on(s)
            pop_it.next
        end
        from
            const_it := constructions.get_new_iterator_on_items
        until
            const_it.is_off
        loop
            s.add_integer(const_it.item.id - product_min)
            const_it.next
        end
        Result := s.serialized_form
    end

feature -- Redefined features

    location: S_PLANET

    owner: S_PLAYER

    shipyard: S_SHIP

    starship_design: S_SHIP_CONSTRUCTION

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


feature -- Operations

    copy(other: like Current) is
    do
        standard_copy(other)
        populators := clone(other.populators)
        constructions := clone(other.constructions)
    end

    is_equal(other: like Current): BOOLEAN is
    do
        Result := id = other.id
    end


feature {STORAGE} -- Saving

    get_class: STRING is "COLONY"

    fields: ITERATOR[TUPLE[STRING, ANY]] is
    local
        a: ARRAY[TUPLE[STRING, ANY]]
        i: INTEGER
    do
        create a.make(1, 0)
        a.add_last(["producing", (producing - product_min).box])
        a.add_last(["produced", produced.box])
        a.add_last(["has_bought", has_bought.box])
        if starship_design /= Void then
            a.add_last(["starship_design", starship_design.design])
        end
        a.add_last(["owner", owner])
        a.add_last(["location", location])
        a.add_last(["population", population.box])
        a.add_last(["preclimate", preclimate.box])
        a.add_last(["pregrav", pregrav.box])
        a.add_last(["extra_popgrowth", extra_population_growth.box])
        a.add_last(["extra_maxpop", extra_max_population.box])
        add_to_fields(a, "populator", populators.get_new_iterator_on_items)
        from
            i := constructions.lower
        until
            i > constructions.upper
        loop
            a.add_last(["construction" + i.to_string, constructions.item(i).id])
            i := i + 1
        end
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
        if starship_design /= Void then
            a.add_last(starship_design.design)
        end
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
                set_id(i.item)
            end
            elems.next
        end
    end

    make_from_storage (elems: ITERATOR [TUPLE [STRING, ANY]]) is
    local
        i: REFERENCE [INTEGER]
        b: REFERENCE [BOOLEAN]
        p: S_POPULATION_UNIT
    do
        from
            populators.clear
            constructions.clear
        until elems.is_off loop
            if elems.item.first.is_equal("producing") then
                i ?= elems.item.second
                producing := i.item + product_min
            elseif elems.item.first.is_equal("produced") then
                i ?= elems.item.second
                produced := i.item
            elseif elems.item.first.is_equal("has_bought") then
                b ?= elems.item.second
                has_bought := b.item
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
            elseif elems.item.first.has_prefix("construction") then
                i ?= elems.item.second
                     -- For if our owner hasn't been made_from_storage yet
                owner.known_constructions.add_by_id(i.item)
                constructions.add(owner.known_constructions.item(i.item), i.item)
            else
                print ("Bad element inside 'colony' tag: " + elems.item.first + "%N")
            end
            elems.next
        end
    end

end -- class S_COLONY
