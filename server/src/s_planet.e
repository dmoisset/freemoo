class S_PLANET
    
inherit
    PLANET
    redefine colony, orbit_center, create_colony end
    STORABLE    
    redefine dependents end

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
    
feature -- Saving

    hash_code: INTEGER is
    do
        Result := Current.to_pointer.hash_code
    end

feature {STORAGE} -- Saving

    get_class: STRING is "PLANET"

    fields: ITERATOR[TUPLE[STRING, ANY]] is
    do
        Result := (<<["colony", colony],
                     ["climate", climate - climate_min],
                     ["mineral", mineral - mnrl_min],
                     ["size", size - plsize_min],
                     ["gravity", gravity - grav_min],
                     ["type", type - type_min],
                     ["special", special - plspecial_min],
                     ["orbit", orbit]
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
    do
    end
    
    make_from_storage (elems: ITERATOR [TUPLE [STRING, ANY]]) is
    local
        i: reference INTEGER
    do
        from
        until elems.is_off loop
            if elems.item.first.is_equal("colony") then
                colony ?= elems.item.second
            elseif elems.item.first.is_equal("climate") then
                i ?= elems.item.second
                climate := i + climate_min
            elseif elems.item.first.is_equal("mineral") then
                i ?= elems.item.second
                mineral := i + mnrl_min
            elseif elems.item.first.is_equal("size") then
                i ?= elems.item.second
                size := i + plsize_min
            elseif elems.item.first.is_equal("gravity") then
                i ?= elems.item.second
                gravity := i + grav_min
            elseif elems.item.first.is_equal("type") then
                i ?= elems.item.second
                type := i + type_min
            elseif elems.item.first.is_equal("special") then
                i ?= elems.item.second
                special := i + plspecial_min
            elseif elems.item.first.is_equal("orbit") then
                i ?= elems.item.second
                orbit := i
            elseif elems.item.first.is_equal("orbit_center") then
                orbit_center ?= elems.item.second
            end
            elems.next
        end
    end

end -- class S_PLANET
