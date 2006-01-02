class S_PLANET

inherit
    PLANET
    redefine colony, orbit_center, create_colony, set_gravity end
    STORABLE
    redefine dependents, primary_keys end

creation make, make_standard

feature

    orbit_center: S_STAR

    colony: S_COLONY

feature

    create_colony(p: S_PLAYER): like colony is
    do
        -- Result := Precursor(p) -- We don't do this because SE chokes
        create Result.make (Current, p)
    end

    set_gravity(new_grav: INTEGER) is
    do
        Precursor(new_grav)
        orbit_center.update_clients
    end

feature -- Saving

    hash_code: INTEGER is
    do
        Result := Current.to_pointer.hash_code
    end

feature {STORAGE} -- Saving

    get_class: STRING is "PLANET"

    primary_keys: ITERATOR[TUPLE[STRING, ANY]] is
    do
        Result := (<<["climate", (climate - climate_min).box] >>).get_new_iterator
    end

    fields: ITERATOR[TUPLE[STRING, ANY]] is
    do
        Result := (<<["colony", colony],
                     ["mineral", (mineral - mnrl_min).box],
                     ["size", (size - plsize_min).box],
                     ["gravity", (gravity - grav_min).box],
                     ["type", (type - type_min).box],
                     ["special", (special - plspecial_min).box],
                     ["orbit", orbit.box]
                     ["orbit_center", orbit_center]
                     >>).get_new_iterator
    end

    dependents: ITERATOR[STORABLE] is
    local
        a: ARRAY[STORABLE]
    do
        create a.make(1,0)
        a.add_last(colony)
        a.add_last(orbit_center)
        Result := a.get_new_iterator
    end

feature {STORAGE} -- Retrieving

    set_primary_keys (elems: ITERATOR [TUPLE [STRING, ANY]]) is
    local
        i: REFERENCE [INTEGER]
    do
        from
        until elems.is_off loop
            if elems.item.first.is_equal("climate") then
                i ?= elems.item.second
                climate := i.item + climate_min
            else
                print ("Unknown primary key '" + elems.item.first + "' in PLANET element%N")
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
            if elems.item.first.is_equal("colony") then
                colony ?= elems.item.second
            elseif elems.item.first.is_equal("mineral") then
                i ?= elems.item.second
                mineral := i.item + mnrl_min
            elseif elems.item.first.is_equal("size") then
                i ?= elems.item.second
                size := i.item + plsize_min
            elseif elems.item.first.is_equal("gravity") then
                i ?= elems.item.second
                gravity := i.item + grav_min
            elseif elems.item.first.is_equal("type") then
                i ?= elems.item.second
                type := i.item + type_min
            elseif elems.item.first.is_equal("special") then
                i ?= elems.item.second
                special := i.item + plspecial_min
            elseif elems.item.first.is_equal("orbit") then
                i ?= elems.item.second
                orbit := i.item
            elseif elems.item.first.is_equal("orbit_center") then
                orbit_center ?= elems.item.second
            end
            elems.next
        end
    end

end -- class S_PLANET
