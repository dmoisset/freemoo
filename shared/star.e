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

    planets: ARRAY [PLANET]
        -- planets orbiting, from inner to outer orbit
        -- has Void at empty orbits

    size: INTEGER

    special: INTEGER

    fleets: DICTIONARY[FLEET, INTEGER]
        -- Subset of galaxy's `fleets', containing fleets that orbit this star.

feature -- Operations on fleets

    add_ship (item: SHIP) is
    do
--        galaxy.add_ship (item)
    end

feature -- Operations on star system
    set_planet (newplanet: PLANET; orbit: INTEGER) is
    require
        newplanet /= Void
        orbit.in_range (1, 5)
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
        !!planets.make (1, 5)
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
        !!planets.make (1, 5)
        !!fleets.make
        special := stspecial_nospecial
    ensure
        distance_to (p) = 0
        name = n
        kind = k
        size = s
        no_planets: planets.occurrences (Void) = 5
    end

invariant
    valid_kind: kind.in_range (kind_min, kind_max)
    valid_size: size.in_range (stsize_min, stsize_max)
    name /= Void
    planets /= Void
    planets.count = 5
    special.in_range (stspecial_min, stspecial_max)

end -- class STAR