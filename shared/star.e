class STAR
    -- Star system

inherit
    UNIQUE_ID
    POSITIONAL
    MAP_CONSTANTS

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

    has_fleet (f: like fleet_type): BOOLEAN is
    do
        Result := fleets.has (f.id)
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
        has_fleet (f)
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

feature {NONE} -- Representation

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