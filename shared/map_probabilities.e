class MAP_PROBABILITIES
  -- Probabilistic Constants for Galaxy Generation

inherit
    MAP_CONSTANTS

feature {NONE} -- Utililty functions

    create_int_ptable (min, max: INTEGER;
                       probs: ARRAY [INTEGER]): FINITE_PTABLE [INTEGER] is
        -- Table of probabilities with ints from min to max (inclusive)
        -- with probabillities given by probs
    require
        probs /= Void
        max-min+1 = probs.count
    local
        a: ARRAY [TUPLE [INTEGER, INTEGER]]
        k: INTEGER
    do
        !!a.make (probs.lower, probs.upper)
        from
            k := probs.lower
        until k > probs.upper loop
            a.put ([k-probs.lower+min, probs @ k], k)
            k := k + 1
        end
        !!Result.make (a)
    end

feature {NONE} -- Star constants

    average_star_kinds: FINITE_PTABLE [INTEGER] is
        -- Probability of a star being certain kind,
        -- in an average galaxy.
    once
        Result := create_int_ptable (kind_blackhole, kind_brown,
            <<40, 105, 145, 136, 144, 404, 26>>)
    end

    orgrich_star_kinds: FINITE_PTABLE [INTEGER] is
        -- Probability of a star being certain kind,
        -- in an organic-rich galaxy.
    once
        Result := create_int_ptable (kind_blackhole, kind_brown,
            <<70, 40, 40, 305, 195, 327, 23>>)
    end

    minrich_star_kinds: FINITE_PTABLE [INTEGER] is
        -- Probability of a star being a certain kind,
        -- in an mineral-rich galaxy.
    once
        Result := create_int_ptable (kind_blackhole, kind_brown,
            <<30, 185, 220, 97, 89, 372, 7>>)
    end

    star_sizes: FINITE_PTABLE [INTEGER] is
        -- Probability of a star being a certain size.
    once
        Result := create_int_ptable (stsize_big, stsize_small,
            <<290, 445, 265>>)
    end

feature {NONE} -- Planet Constants

-- Still few samples for brown stars

    planet_prob: DICTIONARY [INTEGER, INTEGER] is
        -- Probability (percent) of any orbit having a non-null planet,
        -- indexed by star kind.
    once
        !!Result.make
        Result.add (52, kind_bluewhite)
        Result.add (38, kind_white)
        Result.add (60, kind_yellow)
        Result.add (69, kind_orange)
        Result.add (38, kind_red)
        Result.add (5, kind_brown)
        Result.add (0, kind_blackhole)
    end

    planet_types: FINITE_PTABLE [INTEGER] is
        -- Planet type probability, indexed by type.  Independent
        -- of anything else
    once
        Result := create_int_ptable (type_asteroids, type_planet,
            <<200, 211, 589>>)
    end

    average_climates: DICTIONARY [ FINITE_PTABLE [INTEGER], INTEGER] is
        -- Probability Dictionary of (planet probabilities of being a
        -- certain climate), indexed by star kind; for an average galaxy
    once
        !!Result.make
        Result.add (create_int_ptable (climate_toxic, climate_gaia,
                    <<163, 486, 272, 69, 3, 1, 1, 1, 2, 2>>),
                    kind_bluewhite) -- 422 Samples
        Result.add (create_int_ptable (climate_toxic, climate_gaia,
                    <<166, 368, 271, 60, 43, 17, 10, 26, 32, 7>>),
                    kind_white) -- 468 Samples
        Result.add (create_int_ptable (climate_toxic, climate_gaia,
                    <<127, 268, 302, 59, 77, 44, 38, 31, 42, 12>>),
                    kind_yellow) -- 612 Samples
        Result.add (create_int_ptable (climate_toxic, climate_gaia,
                    <<167, 174, 228, 82, 71, 57, 69, 63, 75, 14>>),
                    kind_orange) -- 712 Samples
        Result.add (create_int_ptable (climate_toxic, climate_gaia,
                    <<162, 129, 497, 30, 66, 22, 23, 25, 40, 6>>),
                    kind_red) -- 1087 Samples
        Result.add (create_int_ptable (climate_toxic, climate_gaia,
                    <<208, 292, 100, 200, 100, 20, 20, 20, 30, 10>>),
                    kind_brown) -- 12 Samples
    end

    orgrich_climates: DICTIONARY [FINITE_PTABLE [INTEGER], INTEGER] is
        -- Probability Dictionary of (planet probabilities of being a
        -- certain climate), indexed by star kind; for an organic-rich galaxy
    once
        !!Result.make
        Result.add (create_int_ptable (climate_toxic, climate_gaia,
                    <<130, 370, 222, 267, 6, 1, 1, 1, 1, 1>>),
                    kind_bluewhite) -- 184 Samples
        Result.add (create_int_ptable (climate_toxic, climate_gaia,
                    <<71, 255, 206, 213, 63, 22, 35, 64, 64, 7>>),
                    kind_white) -- 141 Samples
        Result.add (create_int_ptable (climate_toxic, climate_gaia,
                    <<88, 175, 176, 159, 138, 64, 58, 62, 60, 20>>),
                    kind_yellow) -- 1346 Samples
        Result.add (create_int_ptable (climate_toxic, climate_gaia,
                    <<70, 107, 150, 119, 173, 92, 79, 100, 81, 29>>),
                    kind_orange) -- 1022 Samples
        Result.add (create_int_ptable (climate_toxic, climate_gaia,
                    <<128, 66, 370, 64, 236, 36, 32, 32, 35, 1>>),
                    kind_red) -- 872 Samples
        Result.add (create_int_ptable (climate_toxic, climate_gaia,
                    <<200, 300, 100, 200, 100, 20, 20, 20, 30, 10>>),
                    kind_brown) -- 10 Samples
    end

    minrich_climates: DICTIONARY [FINITE_PTABLE [INTEGER], INTEGER] is
        -- Probability Dictionary of (planet probabilities of being a
        -- certain climate), indexed by star kind; for an mineral-rich galaxy
    once
        !!Result.make
        Result.add (create_int_ptable (climate_toxic, climate_gaia,
                    <<129, 542, 260, 57, 7, 1, 1, 1, 1, 1>>),
                    kind_bluewhite) -- 770 Samples
        Result.add (create_int_ptable (climate_toxic, climate_gaia,
                    <<132, 339, 345, 50, 45, 20, 22, 14, 30, 3>>),
                    kind_white) -- 703 Samples
        Result.add (create_int_ptable (climate_toxic, climate_gaia,
                    <<135, 230, 309, 67, 70, 49, 30, 40, 63, 7>>),
                    kind_yellow) -- 430 Samples
        Result.add (create_int_ptable (climate_toxic, climate_gaia,
                    <<117, 175, 290, 56, 100, 43, 61, 61, 77, 20>>),
                    kind_orange) -- 462 Samples
        Result.add (create_int_ptable (climate_toxic, climate_gaia,
                    <<174, 140, 452, 41, 87, 28, 20, 18, 37, 3>>),
                    kind_red) -- 967 Samples
        Result.add (create_int_ptable (climate_toxic, climate_gaia,
                    <<208, 292, 100, 200, 100, 20, 20, 20, 30, 10>>),
                    kind_brown) -- 0 Samples
    end

    planet_sizes: FINITE_PTABLE [INTEGER] is
        -- Probability for a planet being a certain size.
        -- Independent of star-kinds and galaxy ages
    once
        Result := create_int_ptable (plsize_tiny, plsize_huge,
            <<100, 193, 411, 200, 96>>)
    end


    planet_gravs: DICTIONARY [FINITE_PTABLE [INTEGER], INTEGER] is
        -- Planet Gravity probabilities, indexed by star kind
    once
        !!Result.make
        Result.add (create_int_ptable (grav_lowg, grav_highg,
                    <<42, 669, 289>>),
                    kind_bluewhite)
        Result.add (create_int_ptable (grav_lowg, grav_highg,
                    <<106, 701, 193>>),
                    kind_white)
        Result.add (create_int_ptable (grav_lowg, grav_highg,
                    <<138, 703, 159>>),
                    kind_yellow)
        Result.add (create_int_ptable (grav_lowg, grav_highg,
                    <<221, 712, 67>>),
                    kind_orange)
        Result.add (create_int_ptable (grav_lowg, grav_highg,
                    <<296, 662, 42>>),
                    kind_red)
        Result.add (create_int_ptable (grav_lowg, grav_highg,
                    <<136, 773, 91>>),
                    kind_brown)
    end

    planet_minerals: DICTIONARY [FINITE_PTABLE [INTEGER], INTEGER] is
        -- Planet Mineral richness, indexed by star kind
    once
        !!Result.make
        Result.add (create_int_ptable (mnrl_ultrapoor, mnrl_ultrarich,
                    <<1, 1, 397, 416, 185>>),
                    kind_bluewhite)
        Result.add (create_int_ptable (mnrl_ultrapoor, mnrl_ultrarich,
                    <<1, 195, 412, 294, 98>>),
                    kind_white)
        Result.add (create_int_ptable (mnrl_ultrapoor, mnrl_ultrarich,
                    <<1, 303, 404, 207, 85>>),
                    kind_yellow)
        Result.add (create_int_ptable (mnrl_ultrapoor, mnrl_ultrarich,
                    <<104, 402, 390, 103, 1>>),
                    kind_orange)
        Result.add (create_int_ptable (mnrl_ultrapoor, mnrl_ultrarich,
                    <<186, 383, 423, 4, 4>>),
                    kind_red)
        Result.add (create_int_ptable (mnrl_ultrapoor, mnrl_ultrarich,
                    <<50, 110, 610, 180, 50>>),
                    kind_brown)
    end

end -- class MAP_PROBABILITIES
