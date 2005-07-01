class S_STAR

inherit
    STAR
    undefine
        copy, is_equal
    redefine
        set_planet, set_special, set_name, make, make_defaults,
        planet_type
    end
    STORABLE
    rename
        hash_code as id
    redefine
        dependents, primary_keys, copy, is_equal
    end
    SERVICE
    undefine copy, is_equal
    redefine subscription_message end

creation make, make_defaults

feature {NONE} -- Creation

    make_defaults is
    do
        Precursor
        make_unique_id
    end

    make (p: POSITIONAL; n: STRING; k: INTEGER; s: INTEGER) is
    do
        Precursor(p, n, k, s)
        make_unique_id
    end

feature -- Redefined Features

    subscription_message (service_id: STRING): STRING is
    local
        s: SERIALIZER2
        i: ITERATOR [like planet_type]
    do
        !!s.make
        -- Setup id upon first subscription
        if s_id = Void then
            s_id := service_id
        end
        s.add_string (name)
        if wormhole = Void then
            s.add_integer(-1)
        else
            s.add_integer(wormhole.id)
        end
        s.add_integer (Max_planets - planets.fast_occurrences(Void))
        from
            i := planets.get_new_iterator
        until i.is_off loop
            if i.item /= Void then
                s.add_tuple (<<i.item.orbit,
                               i.item.size - i.item.plsize_min,
                               i.item.climate - i.item.climate_min,
                               i.item.mineral - i.item.mnrl_min,
                               i.item.gravity - i.item.grav_min,
                               i.item.type - i.item.type_min,
                               i.item.special - i.item.plspecial_min>>)
            end
            i.next
        end
        Result := s.serialized_form
    end

feature {MAP_GENERATOR} -- Redefined

    set_planet (newplanet: like planet_type; orbit: INTEGER) is
    do
        Precursor(newplanet, orbit)
        update_clients
    end

    set_special (new_special: INTEGER) is
    do
        Precursor(new_special)
        update_clients
    end

    set_name (new_name: STRING) is
    do
        Precursor(new_name)
        update_clients
    end

feature -- Access

    s_id: STRING
        -- Name of the service we provide

feature -- Operations

    update_clients is
    do
        if s_id /= Void then
            send_message (s_id, subscription_message (s_id))
        end
    end

feature -- Operations
    
    copy(other: like Current) is
    do
        standard_copy(other)
        planets := clone(other.planets)
    end
    
    is_equal(other: like Current): BOOLEAN is
    do
        Result := id = other.id
    end
    
feature {STORAGE} -- Saving

    get_class: STRING is "STAR"
    
    fields: ITERATOR[TUPLE[STRING, ANY]] is
    local
        a: ARRAY[TUPLE[STRING, ANY]]
    do
        create a.make(1, 0)
        a.add_last(["name", name])
        a.add_last(["kind", kind])
        a.add_last(["size", size])
        a.add_last(["special", special])
        a.add_last(["x", x])
        a.add_last(["y", y])
        a.add_last(["wormhole", wormhole])
        add_to_fields(a, "planet", planets.get_new_iterator)
        Result := a.get_new_iterator
    end
    
    primary_keys: ITERATOR[TUPLE[STRING, ANY]] is
    do
        Result := (<<["id", id] >>).get_new_iterator
    end
    
    dependents: ITERATOR[STORABLE] is
    local
        a: ARRAY[STORABLE]
    do
        create a.make(1, 0)
        a.add_last(wormhole)
        add_dependents_to(a, planets.get_new_iterator)
        Result := a.get_new_iterator
    end
    
feature {STORAGE} -- Retrieving
   
    set_primary_keys (elems: ITERATOR [TUPLE [STRING, ANY]]) is
    local
        i: reference INTEGER
    do
        from
        until elems.is_off loop
            if elems.item.first.is_equal("id") then
                i ?= elems.item.second
                id := i
            end
            elems.next
        end
    end
    
    make_from_storage (elems: ITERATOR [TUPLE [STRING, ANY]]) is
    local
        n: INTEGER
        i: reference INTEGER
        r: reference REAL
        planet: like planet_type
    do
        from
            planets.set_all_with(Void)
        until elems.is_off loop
            if elems.item.first.is_equal("name") then
                name ?= elems.item.second
            elseif elems.item.first.is_equal("kind") then
                i ?= elems.item.second
                kind := i
            elseif elems.item.first.is_equal("size") then
                i ?= elems.item.second
                size := i
            elseif elems.item.first.is_equal("special") then
                i ?= elems.item.second
                special := i
            elseif elems.item.first.is_equal("x") then
                r ?= elems.item.second
                x := r
            elseif elems.item.first.is_equal("y") then
                r ?= elems.item.second
                y := r
            elseif elems.item.first.is_equal("wormhole") then
                wormhole ?= elems.item.second
            elseif elems.item.first.has_prefix("planet") then
                n := elems.item.first.last.value
                planet ?= elems.item.second
                planets.put (planet, n + 1)
            end
                elems.next
            end
    end

feature {NONE} -- Internal
    
    planet_type: S_PLANET

end -- class S_STAR
