class S_FLEET

inherit
    SERVICE
    redefine subscription_message end
    FLEET
    redefine
        set_destination, add_ship, remove_ship, split, move,
        join, clear_ships, orbit_center, owner, ship_type,
        colonize_order
    end
    STORABLE
    rename
        hash_code as id
    redefine
        dependents, primary_keys, copy, is_equal
    end

creation make

feature -- Redefined features

    orbit_center: S_STAR
    
    owner: S_PLAYER

    subscription_message (service_id: STRING): STRING is
        -- Complete information of fleet, with info about ships and
        -- everything
    local
        s: SERIALIZER2
        i: ITERATOR[like ship_type]
    do
        !!s.make
        -- Currently just has same info as scanner
        s.add_tuple(<< owner, eta >>)
        if orbit_center/=Void then
            s.add_integer(orbit_center.id)
        else
            s.add_integer(-1)
        end
        if destination/=Void then
            s.add_integer(destination.id)
        else
            s.add_integer(-1)
        end
        s.add_boolean (has_colonization_orders)
        s.add_integer (ship_count)
        serialize_on (s)
        from i := get_new_iterator until i.is_off loop
            s.add_tuple(<<i.item.id, i.item.ship_type - i.item.ship_type_min>>)
            i.item.serialize_on(s)
            i.next
        end
        Result := s.serialized_form
    end

    set_destination (dest: like destination) is
    do
        Precursor (dest)
        update_clients
    end

    add_ship(sh: like ship_type) is
    do
        Precursor(sh)
        update_clients
    end

    remove_ship(sh: like ship_type) is
    do
        Precursor(sh)
        update_clients
    end

    split (sh: ITERATOR [like ship_type]) is
    do
        Precursor (sh)
        update_clients
    end
    
    join (other: like Current) is
    do
        Precursor (other)
        update_clients
    end

    clear_ships is
    do
        Precursor
        update_clients
    end
    
    move is
    local
        old_msg, new_msg: STRING
    do
        old_msg := subscription_message("fleet" + id.to_string)
        Precursor
        new_msg := subscription_message("fleet" + id.to_string)
        if not equal (old_msg, new_msg) and then registry /= Void then
            send_message("fleet" + id.to_string, new_msg)
        end
    end
    
    colonize_order is
    do
        Precursor
        update_clients
    end

feature -- Operations
    
    copy(other: like Current) is
    do
        standard_copy(other)
        ships := clone(other.ships)
    end
    
    is_equal(other: like Current): BOOLEAN is
    do
        Result := id = other.id
    end
    

feature {STORAGE} -- Saving
    
    get_class: STRING is "FLEET"
    
    fields: ITERATOR[TUPLE[STRING, ANY]] is
    local
        a: ARRAY[TUPLE[STRING, ANY]]
    do
        create a.make(1, 0)
        a.add_last(["x", x])
        a.add_last(["y", y])
        a.add_last(["orbit_center", orbit_center])
        a.add_last(["owner", owner])
        a.add_last(["destination", destination])
        a.add_last(["has_colonization_orders", has_colonization_orders])
        a.add_last(["eta", eta])
        a.add_last(["current_speed", current_speed]) 
        add_to_fields(a, "ship", ships.get_new_iterator_on_items)
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
        a.add_last(orbit_center)
        a.add_last(owner)
        a.add_last(destination)
        add_dependents_to(a, ships.get_new_iterator_on_items)
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
        i: reference INTEGER
        b: reference BOOLEAN
        r: reference REAL
        s: like ship_type
    do
        from
            ships.clear
        until elems.is_off loop
            if elems.item.first.is_equal("x") then
                r ?= elems.item.second
                x := r
            elseif elems.item.first.is_equal("y") then
                r ?= elems.item.second
                y := r
            elseif elems.item.first.is_equal("orbit_center") then
                orbit_center ?= elems.item.second
            elseif elems.item.first.is_equal("owner") then
                owner ?= elems.item.second
            elseif elems.item.first.is_equal("destination") then
                destination ?= elems.item.second
            elseif elems.item.first.is_equal("has_colonization_orders") then
                b ?= elems.item.second
                has_colonization_orders := b
            elseif elems.item.first.is_equal("eta") then
                i ?= elems.item.second
                eta := i
            elseif elems.item.first.is_equal("current_speed") then
                r ?= elems.item.second
                current_speed := r
            elseif elems.item.first.has_prefix("ship") then
                s ?= elems.item.second
                ships.add (s, s.id)
            end
            elems.next
        end
    end

feature

    update_clients is
    do
        if registry /= Void then
            send_message("fleet" + id.to_string, subscription_message("fleet" + id.to_string))
        end
    end
    
feature
    
    ship_type: S_SHIP
    
end -- class S_FLEET
