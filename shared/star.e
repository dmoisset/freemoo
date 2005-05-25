class STAR
    -- Star system

inherit
    UNIQUE_ID
    select id end
    POSITIONAL
    MAP_CONSTANTS
    STORABLE
    rename
	hash_code as id
    redefine
	dependents, primary_keys, copy, is_equal
    end

creation
    make, make_defaults

feature -- Access

    name: STRING
        -- Star name

    kind: INTEGER
        -- star class: see `kind_*' constants. Determines color, and
        -- possibilities for having planets

    size: INTEGER

    special: INTEGER

    Max_planets: INTEGER is 5

    get_new_iterator_on_planets: ITERATOR [PLANET] is
    do
        Result := planets.get_new_iterator
    end

    planet_at (orbit: INTEGER): PLANET is
    do
        Result := planets @ orbit
    end

    has_fleet (fid: INTEGER): BOOLEAN is
    do
        Result := fleets.has (fid)
    end

    fleet_with_id (fid: INTEGER): like fleet_type is
    require
        has_fleet (fid)
    do
        Result := fleets @ fid
    end

    fleet_count: INTEGER is
    do
        Result := fleets.count
    end

    get_new_iterator_on_fleets: ITERATOR [like fleet_type] is
    do
        Result := fleets.get_new_iterator_on_items
    end
    
feature -- Operations on fleets

    add_fleet (f: like fleet_type) is
    require
        f.orbit_center = Current
    do
        fleets.add (f, f.id)
    end

    remove_fleet (f: like fleet_type) is
    require
        has_fleet (f.id)
    do
        fleets.remove (f.id)
    end

    store_fleets_in (buffer: COLLECTION [like fleet_type]) is
    require
        buffer /= Void
    do
        fleets.item_map_in (buffer)
    end

    clear_fleets is
    do
        fleets.clear
    end
    
feature -- Operations on star system

    set_planet (newplanet: PLANET; orbit: INTEGER) is
    require
        newplanet /= Void
        orbit.in_range (1, Max_planets)
    do
        newplanet.set_orbit (orbit)
        planets.put (newplanet, orbit)
    ensure
        planets.item (orbit) = newplanet
        consistent_orbits: planets.item (orbit).orbit = orbit
    end

    set_special (new_special: INTEGER) is
    require
        new_special.in_range (stspecial_min, stspecial_max)
    do
        special := new_special
    ensure
        special = new_special
    end

    set_size (new_size: INTEGER) is
    require
        new_size.in_range (stsize_min, stsize_max)
    do
        size := new_size
    ensure
        size = new_size
    end

    set_name (new_name: STRING) is
    require
        new_name /= Void
    do
        name := new_name
    ensure
        name = new_name
    end

    set_kind (new_kind: INTEGER) is
    require
        new_kind /= Void
        valid_kind: kind.in_range (kind_min, kind_max)
    do
        kind := new_kind
    ensure
        kind = new_kind
    end

feature {NONE} -- Creation

    make_defaults is
    do
        make_unique_id
        kind := kind_min
        name := ""
        size := stsize_min
        !!planets.make (1, Max_planets)
        !!fleets.make
        special := stspecial_nospecial
    end

    make (p:POSITIONAL; n:STRING; k:INTEGER; s:INTEGER) is
    require
        n /= Void
        p /= Void
        k.in_range(kind_min, kind_max)
        s.in_range(stsize_min, stsize_max)
    do
        make_unique_id
        name := n
        move_to (p)
        kind := k
        size := s
        !!planets.make (1, Max_planets)
        !!fleets.make
        special := stspecial_nospecial
    ensure
        distance_to (p) = 0
        name = n
        kind = k
        size = s
        no_planets: planets.occurrences (Void) = Max_planets
    end
    
feature -- Operations
    
    copy(other: like Current) is
    do
	standard_copy(other)
	planets := clone(other.planets)
	fleets := clone(other.fleets)
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
	add_to_fields(a, "planet", planets.get_new_iterator)
	add_to_fields(a, "fleet", fleets.get_new_iterator_on_items)
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
	a := clone(planets)
	add_dependents_to(a, fleets.get_new_iterator_on_items)
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
	planet: PLANET
	fleet: like fleet_type
    do
	from
	    planets.set_all_with(Void)
	    fleets.clear
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
	    elseif elems.item.first.is_equal("id") then
		i ?= elems.item.second
		id := i
	    elseif elems.item.first.has_prefix("planet") then
		n := elems.item.first.last.value
		planet ?= elems.item.second
		planets.put (planet, n + 1)
	    elseif elems.item.first.has_prefix("fleet") then
		fleet ?= elems.item.second
		fleets.add(fleet, fleet.id)
	    end
	    elems.next
	end
    end

	
	
feature {STAR} -- Representation

    planets: ARRAY [PLANET]
        -- planets orbiting, from inner to outer orbit
        -- has Void at empty orbits

    fleets: DICTIONARY [like fleet_type, INTEGER]
        -- Subset of galaxy's `fleets', containing fleets that orbit this star.

feature {NONE} -- Internal

    fleet_type: FLEET
        -- Anchor for type declarations.
    
invariant
    valid_kind: kind.in_range (kind_min, kind_max)
    valid_size: size.in_range (stsize_min, stsize_max)
    name /= Void
    planets /= Void
    planets.count = Max_planets
    special.in_range (stspecial_min, stspecial_max)

end -- class STAR
