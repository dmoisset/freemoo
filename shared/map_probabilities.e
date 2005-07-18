class MAP_PROBABILITIES
  -- Probabilistic Constants for Galaxy Generation

inherit
    MAP_CONSTANTS

feature {NONE} -- Utililty functions

    load_int_ptable (s: COMMENTED_TEXT_FILE; min, max: INTEGER) is
        -- Read a sequence of integers from `s' and build a finite
        -- probability table for items from `min' to `max' to be
        -- stored at `last_int_ptable'
    local
        probs: ARRAY [INTEGER]
        k: INTEGER
    do
        s.read_nonempty_line
        probs := str_array_to_int_array (s.last_line.split)
            check max-min+1 = probs.count end
        !!last_int_ptable.make
        from k := probs.lower until k > probs.upper loop
            last_int_ptable.add (k-probs.lower+min, probs @ k)
            k := k + 1
        end
    end

    load_int_ptables (f: COMMENTED_TEXT_FILE; min, max: INTEGER) is
        -- load an integer probabiliy table for each star kind from `f'.
        -- Each table has items ranging from `min' to `max'. Store
        -- into `last_int_ptables'
    local
        i: INTEGER
    do
        !!last_int_ptables.make (kind_min, kind_max)
        from i := kind_min until i > kind_max loop
            load_int_ptable(f, min, max)
            last_int_ptables.put (last_int_ptable, i)
            i := i + 1
        end
    end

    last_int_ptable: FINITE_PTABLE [INTEGER]
        -- Last probability table read

    last_int_ptables: ARRAY [FINITE_PTABLE [INTEGER]]
        -- Last probability table sequence read

feature -- Operations

    load (subdir: STRING) is
        -- Load constants. Take age dependant constants from `subdir'
    local
        f: COMMENTED_TEXT_FILE
    do
        pkg_system.open_file ("galaxy/sizes")
        !!f.make (pkg_system.last_file_open)
        load_int_ptable (f, stsize_small, stsize_big)
        star_sizes := last_int_ptable

        pkg_system.open_file ("galaxy/planets")
        !!f.make (pkg_system.last_file_open)
        load_int_ptable (f, plsize_tiny, plsize_huge)
        planet_sizes := last_int_ptable
        load_int_ptable (f, type_asteroids, type_planet)
        planet_types := last_int_ptable

        pkg_system.open_file ("galaxy/stars")
        !!f.make (pkg_system.last_file_open)
        f.read_nonempty_line
        planet_prob := str_array_to_int_array (f.last_line.split)
        planet_prob.reindex (kind_min)
        load_int_ptables (f, grav_lowg, grav_highg)
        planet_gravs := last_int_ptables
        load_int_ptables (f, mnrl_ultrapoor, mnrl_ultrarich)
        planet_minerals := last_int_ptables
        load_int_ptable(f, stspecial_min, stspecial_max - 1) -- Without Orion
        star_specials := last_int_ptable

        pkg_system.open_file ("galaxy/"+subdir+"/stars")
        !!f.make (pkg_system.last_file_open)
        load_int_ptable(f, kind_min, kind_max)
        star_kinds := last_int_ptable
        load_int_ptables (f, climate_toxic, climate_gaia)
        planet_climates := last_int_ptables
    end

feature {NONE} -- Access -- Star constants

    star_kinds: FINITE_PTABLE [INTEGER]
        -- Probability of a star being certain kind

    star_sizes: FINITE_PTABLE [INTEGER]
        -- Probability of a star being a certain size.

    star_specials: FINITE_PTABLE[INTEGER]
        -- Probability of a star having a certain special

feature {NONE} --Access -- Planet Constants

-- Still few samples for brown stars

    planet_prob: ARRAY [INTEGER]
        -- Probability (percent) of any orbit having a non-null planet,
        -- indexed by star kind.

    planet_types: FINITE_PTABLE [INTEGER]
        -- Planet type probability, indexed by type.

    planet_climates: ARRAY [FINITE_PTABLE [INTEGER]]
        -- Probability Dictionary of (planet probabilities of being a
        -- certain climate), indexed by star kind.

    planet_sizes: FINITE_PTABLE [INTEGER]
        -- Probability for a planet being a certain size.
        -- Independent of star-kinds and galaxy ages

    planet_gravs: ARRAY [FINITE_PTABLE [INTEGER]]
        -- Planet Gravity probabilities, indexed by star kind

    planet_minerals: ARRAY [FINITE_PTABLE [INTEGER]]
        -- Planet Mineral richness, indexed by star kind

end -- class MAP_PROBABILITIES
