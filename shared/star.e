class STAR
    -- Star system

inherit
    UNIQUE_ID
    select id end
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
        -- star special.  One of stspecial_* constants.  Don't confuse
        -- with planet specials!

    wormhole: like Current

    Max_planets: INTEGER is 5

    get_new_iterator_on_planets: ITERATOR [like planet_type] is
    do
        Result := planets.get_new_iterator
    end

    planet_at (orbit: INTEGER): like planet_type is
    require
        orbit.in_range(1, Max_planets)
    do
        Result := planets @ orbit
    end

    has_colonizable_planet: BOOLEAN is
        -- Does this star have a colonizable planet?
    local
        i: INTEGER
    do
        from
            i := 1
        until i > Max_planets or Result loop
            Result := planets @ i /= Void and then
                      (planets @ i).type = (planets @ i).type_planet and then
                      (planets @ i).colony = Void
            i := i + 1
        end
    end

feature -- Operations on star system

    set_planet (newplanet: like planet_type; orbit: INTEGER) is
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

    setup_wormhole_to(other: like Current) is
    require
        other /= Void
    do
        special := stspecial_wormhole
        wormhole := other
        other.set_wormhole(Current)
    ensure
        special = stspecial_wormhole
        other.special = stspecial_wormhole
        wormhole = other
        other.wormhole = Current
    end

    take_down_wormhole is
    do
        if special = stspecial_wormhole then
            wormhole.set_wormhole(Void)
            wormhole := Void
            special := stspecial_nospecial
        end
    ensure
        wormhole = Void
        old special = stspecial_wormhole implies special = stspecial_nospecial
    end

    planet_with_special: like planet_type is
    require
        special = stspecial_planetspecial
    local
        it: ITERATOR[like planet_type]
    do
        from
            it := get_new_iterator_on_planets
        until
            it.is_off or Result /= Void
        loop
            if it.item /= Void and then it.item.special /= plspecial_nospecial then
                Result := it.item
            end
            it.next
        end
    ensure
        Result /= Void
        Result.special /= plspecial_nospecial
    end

    collect_special(lucky_guy: like player_type) is
    local
        planet: like planet_type
        constants: PRODUCTION_CONSTANTS
        colony: COLONY
    do
        if special = stspecial_debris then
            lucky_guy.update_money(50)
            special := stspecial_nospecial
        elseif special = stspecial_piratecache then
            lucky_guy.update_money(100)
            special := stspecial_nospecial
        elseif special = stspecial_planetspecial and then
                planet_with_special.special = plspecial_splinter then
            create constants
            planet := planet_with_special
            colony := planet.create_colony(lucky_guy)
            colony.add_populator(constants.task_farming)
            colony.add_populator(constants.task_industry)
            planet.set_special(plspecial_nospecial)
            special := stspecial_nospecial
        end
    end

feature -- Factory Methods

    create_planet: like planet_type is
    do
        create Result.make_standard(Current)
    end


feature {NONE} -- Creation

    make_defaults is
    do
        make_unique_id
        kind := kind_min
        name := ""
        size := stsize_min
        !!planets.make (1, Max_planets)
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
        special := stspecial_nospecial
    ensure
        distance_to (p) = 0
        name = n
        kind = k
        size = s
        no_planets: planets.occurrences (Void) = Max_planets
    end

feature {STAR} -- Representation

    planets: ARRAY [like planet_type]
        -- planets orbiting, from inner to outer orbit
        -- has Void at empty orbits

    set_wormhole (new_wormhole: like Current) is
    do
        wormhole := new_wormhole
        if new_wormhole = Void then
            special := stspecial_nospecial
        else
            special := stspecial_wormhole
        end
    ensure
        wormhole = new_wormhole
        (special = stspecial_wormhole) = (new_wormhole /= Void)
        (special = stspecial_nospecial) = (new_wormhole = Void)
    end

feature {NONE} -- Internal

    planet_type: PLANET
        -- Anchor for type declarations.

    player_type: PLAYER

invariant
    valid_kind: kind.in_range (kind_min, kind_max)
    valid_size: size.in_range (stsize_min, stsize_max)
    name /= Void
    planets /= Void
    planets.count = Max_planets
    planets.lower = 1
    special.in_range (stspecial_min, stspecial_max)
end -- class STAR
