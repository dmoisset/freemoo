class MAP_PROBABILITIES
  -- Probabilistic Constants for Galaxy Generation

inherit
    MAP_CONSTANTS

feature {NONE} -- Star constants

    average_star_kinds: FINITE_PTABLE [INTEGER] is
        -- Accumulative probability of a star being certain kind,
        -- in an average galaxy.
    once
        !!Result.make (<<[40, kind_blackhole],
                         [145, kind_bluewhite],
                         [290, kind_white],
                         [426, kind_yellow],
                         [570, kind_orange],
                         [974, kind_red],
                         [1000, kind_brown]>>)
    end

    orgrich_star_kinds: FINITE_PTABLE [INTEGER] is
        -- Accumulative probability of a star being certain kind,
        -- in an organic-rich galaxy.
    once
        !!Result.make (<<[70, kind_blackhole],
                         [110, kind_bluewhite],
                         [150, kind_white],
                         [455, kind_yellow],
                         [650, kind_orange],
                         [977, kind_red],
                         [1000, kind_brown]>>)
    end

    minrich_star_kinds: FINITE_PTABLE [INTEGER] is
        -- Accumulative probability of a star being a certain kind,
        -- in an mineral-rich galaxy.
    once
        !!Result.make (<<[30, kind_blackhole],
                         [215, kind_bluewhite],
                         [435, kind_white],
                         [532, kind_yellow],
                         [621, kind_orange],
                         [993, kind_red],
                         [1000, kind_brown]>>)
    end

    star_sizes: FINITE_PTABLE [INTEGER] is
        -- Accumulative probability of a star being a certain size.
    once
        !!Result.make (<<[290, stsize_big],
                         [735, stsize_medium],
                         [1000, stsize_small]>>)
    end

feature {NONE} -- Planet Constants

-- Still few samples for brown stars

    planet_prob: DICTIONARY [INTEGER, INTEGER] is
        -- Probability of any orbit having a non-null planet,
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
        -- planet type probability, indexed by type.  Independent
        -- of anything else
    once
        !!Result.make (<<[200, type_asteroids],
                         [411, type_gasgiant],
                         [1000, type_planet]>>)
    end

    average_climates: DICTIONARY [ FINITE_PTABLE [INTEGER], INTEGER] is
        -- Probability Dictionary of (planet probabilities of being a
        -- certain climate), indexed by star kind; for an average galaxy
    once
        !!Result.make
        Result.add (create {FINITE_PTABLE [INTEGER]}.make (<<
            [163, climate_toxic],
            [649, climate_radiated],
            [921, climate_barren],
            [990, climate_desert],
            [993, climate_tundra],
            [994, climate_ocean],
            [995, climate_swamp],
            [996, climate_arid],
            [998, climate_terran],
            [1000, climate_gaia]>>), kind_bluewhite) -- 422 Samples
        Result.add (create {FINITE_PTABLE [INTEGER]}.make (<<
            [166, climate_toxic],
            [534, climate_radiated],
            [805, climate_barren],
            [865, climate_desert],
            [908, climate_tundra],
            [925, climate_ocean],
            [935, climate_swamp],
            [961, climate_arid],
            [993, climate_terran],
            [1000, climate_gaia]>>), kind_white) -- 468 Samples
        Result.add (create {FINITE_PTABLE [INTEGER]}.make (<<
            [127, climate_toxic],
            [395, climate_radiated],
            [697, climate_barren],
            [756, climate_desert],
            [833, climate_tundra],
            [877, climate_ocean],
            [915, climate_swamp],
            [946, climate_arid],
            [988, climate_terran],
            [1000, climate_gaia]>>), kind_yellow) -- 612 Samples
        Result.add (create {FINITE_PTABLE [INTEGER]}.make (<<
            [167, climate_toxic],
            [341, climate_radiated],
            [569, climate_barren],
            [651, climate_desert],
            [722, climate_tundra],
            [779, climate_ocean],
            [848, climate_swamp],
            [911, climate_arid],
            [986, climate_terran],
            [1000, climate_gaia]>>), kind_orange) -- 712 Samples
        Result.add (create {FINITE_PTABLE [INTEGER]}.make (<<
            [162, climate_toxic],
            [291, climate_radiated],
            [788, climate_barren],
            [818, climate_desert],
            [884, climate_tundra],
            [906, climate_ocean],
            [929, climate_swamp],
            [954, climate_arid],
            [994, climate_terran],
            [1000, climate_gaia]>>), kind_red) -- 1087 Samples
        Result.add (create {FINITE_PTABLE [INTEGER]}.make (<<
            [208, climate_toxic],
            [500, climate_radiated],
            [600, climate_barren],
            [800, climate_desert],
            [900, climate_tundra],
            [920, climate_ocean],
            [940, climate_swamp],
            [960, climate_arid],
            [990, climate_terran],
            [1000, climate_gaia]>>), kind_brown) -- 12 Samples
    end

    orgrich_climates: DICTIONARY [FINITE_PTABLE [INTEGER], INTEGER] is
        -- Probability Dictionary of (planet probabilities of being a
        -- certain climate), indexed by star kind; for an organic-rich galaxy
    once
        !!Result.make
        Result.add (create {FINITE_PTABLE [INTEGER]}.make (<<
            [130, climate_toxic],
            [500, climate_radiated],
            [722, climate_barren],
            [989, climate_desert],
            [995, climate_tundra],
            [996, climate_ocean],
            [997, climate_swamp],
            [998, climate_arid],
            [999, climate_terran],
            [1000, climate_gaia]>>), kind_bluewhite) -- 184 Samples
        Result.add (create {FINITE_PTABLE [INTEGER]}.make (<<
            [71, climate_toxic],
            [326, climate_radiated],
            [532, climate_barren],
            [745, climate_desert],
            [808, climate_tundra],
            [830, climate_ocean],
            [865, climate_swamp],
            [929, climate_arid],
            [993, climate_terran],
            [1000, climate_gaia]>>), kind_white) -- 141 Samples
        Result.add (create {FINITE_PTABLE [INTEGER]}.make (<<
            [88, climate_toxic],
            [263, climate_radiated],
            [439, climate_barren],
            [598, climate_desert],
            [736, climate_tundra],
            [800, climate_ocean],
            [858, climate_swamp],
            [920, climate_arid],
            [980, climate_terran],
            [1000, climate_gaia]>>), kind_yellow) -- 1346 Samples
        Result.add (create {FINITE_PTABLE [INTEGER]}.make (<<
            [70, climate_toxic],
            [177, climate_radiated],
            [327, climate_barren],
            [446, climate_desert],
            [619, climate_tundra],
            [711, climate_ocean],
            [790, climate_swamp],
            [890, climate_arid],
            [971, climate_terran],
            [1000, climate_gaia]>>), kind_orange) -- 1022 Samples
        Result.add (create {FINITE_PTABLE [INTEGER]}.make (<<
            [128, climate_toxic],
            [194, climate_radiated],
            [564, climate_barren],
            [628, climate_desert],
            [864, climate_tundra],
            [900, climate_ocean],
            [932, climate_swamp],
            [964, climate_arid],
            [999, climate_terran],
            [1000, climate_gaia]>>), kind_red) -- 872 Samples
        Result.add (create {FINITE_PTABLE [INTEGER]}.make (<<
            [200, climate_toxic],
            [500, climate_radiated],
            [600, climate_barren],
            [800, climate_desert],
            [900, climate_tundra],
            [920, climate_ocean],
            [940, climate_swamp],
            [960, climate_arid],
            [990, climate_terran],
            [1000, climate_gaia]>>), kind_brown) -- 10 Samples
    end

    minrich_climates: DICTIONARY [FINITE_PTABLE [INTEGER], INTEGER] is
        -- Probability Dictionary of (planet probabilities of being a
        -- certain climate), indexed by star kind; for an mineral-rich galaxy
    once
        !!Result.make
        Result.add (create {FINITE_PTABLE [INTEGER]}.make (<<
            [129, climate_toxic],
            [671, climate_radiated],
            [931, climate_barren],
            [988, climate_desert],
            [995, climate_tundra],
            [996, climate_ocean],
            [997, climate_swamp],
            [998, climate_arid],
            [999, climate_terran],
            [1000, climate_gaia]>>), kind_bluewhite) -- 770 Samples
        Result.add (create {FINITE_PTABLE [INTEGER]}.make (<<
            [132, climate_toxic],
            [471, climate_radiated],
            [816, climate_barren],
            [866, climate_desert],
            [911, climate_tundra],
            [931, climate_ocean],
            [953, climate_swamp],
            [967, climate_arid],
            [997, climate_terran],
            [1000, climate_gaia]>>), kind_white) -- 703 Samples
        Result.add (create {FINITE_PTABLE [INTEGER]}.make (<<
            [135, climate_toxic],
            [365, climate_radiated],
            [674, climate_barren],
            [741, climate_desert],
            [811, climate_tundra],
            [860, climate_ocean],
            [890, climate_swamp],
            [930, climate_arid],
            [993, climate_terran],
            [1000, climate_gaia]>>), kind_yellow) -- 430 Samples
        Result.add (create {FINITE_PTABLE [INTEGER]}.make (<<
            [117, climate_toxic],
            [292, climate_radiated],
            [582, climate_barren],
            [638, climate_desert],
            [738, climate_tundra],
            [781, climate_ocean],
            [842, climate_swamp],
            [903, climate_arid],
            [980, climate_terran],
            [1000, climate_gaia]>>), kind_orange) -- 462 Samples
        Result.add (create {FINITE_PTABLE [INTEGER]}.make (<<
            [174, climate_toxic],
            [314, climate_radiated],
            [766, climate_barren],
            [807, climate_desert],
            [894, climate_tundra],
            [922, climate_ocean],
            [942, climate_swamp],
            [960, climate_arid],
            [997, climate_terran],
            [1000, climate_gaia]>>), kind_red) -- 967 Samples
        Result.add (create {FINITE_PTABLE [INTEGER]}.make (<<
            [208, climate_toxic],
            [500, climate_radiated],
            [600, climate_barren],
            [800, climate_desert],
            [900, climate_tundra],
            [920, climate_ocean],
            [940, climate_swamp],
            [960, climate_arid],
            [990, climate_terran],
            [1000, climate_gaia]>>), kind_brown) -- 0 Samples
    end

    planet_sizes: FINITE_PTABLE [INTEGER] is
        -- Accumulated probability for a planet being a certain size.
        -- Independent of star-kinds and galaxy ages
    once
        !!Result.make (<<[100, plsize_tiny],
                         [293, plsize_small],
                         [704, plsize_medium],
                         [904, plsize_large],
                         [1000, plsize_huge]>>)
    end


    planet_gravs: DICTIONARY [FINITE_PTABLE [INTEGER], INTEGER] is
        -- Planet Gravity probabilities, indexed by star kind
    once
        !!Result.make
        Result.add (create {FINITE_PTABLE [INTEGER]}.make (<<
            [42, grav_lowg],
            [711, grav_normalg],
            [1000, grav_highg]>>), kind_bluewhite)
        Result.add (create {FINITE_PTABLE [INTEGER]}.make (<<
            [106, grav_lowg],
            [807, grav_normalg],
            [1000, grav_highg]>>), kind_white)
        Result.add (create {FINITE_PTABLE [INTEGER]}.make (<<
            [138, grav_lowg],
            [841, grav_normalg],
            [1000, grav_highg]>>), kind_yellow)
        Result.add (create {FINITE_PTABLE [INTEGER]}.make (<<
            [221, grav_lowg],
            [933, grav_normalg],
            [1000, grav_highg]>>), kind_orange)
        Result.add (create {FINITE_PTABLE [INTEGER]}.make (<<
            [296, grav_lowg],
            [958, grav_normalg],
            [1000, grav_highg]>>), kind_red)
        Result.add (create {FINITE_PTABLE [INTEGER]}.make (<<
            [136, grav_lowg],
            [909, grav_normalg],
            [1000, grav_highg]>>), kind_brown)
    end

    planet_minerals: DICTIONARY[ FINITE_PTABLE [INTEGER], INTEGER] is
        -- planet Mineral richness, indexed by star kind
    once
        !!Result.make
        Result.add (create {FINITE_PTABLE [INTEGER]}.make (<<
            [1, mnrl_ultrapoor],
            [2, mnrl_poor],
            [399, mnrl_abundant],
            [815, mnrl_rich],
            [1000, mnrl_ultrarich]>>), kind_bluewhite)
        Result.add (create {FINITE_PTABLE [INTEGER]}.make (<<
            [1, mnrl_ultrapoor],
            [196, mnrl_poor],
            [608, mnrl_abundant],
            [902, mnrl_rich],
            [1000, mnrl_ultrarich]>>), kind_white)
        Result.add (create {FINITE_PTABLE [INTEGER]}.make (<<
            [1, mnrl_ultrapoor],
            [304, mnrl_poor],
            [708, mnrl_abundant],
            [915, mnrl_rich],
            [1000, mnrl_ultrarich]>>), kind_yellow)
        Result.add (create {FINITE_PTABLE [INTEGER]}.make (<<
            [104, mnrl_ultrapoor],
            [506, mnrl_poor],
            [896, mnrl_abundant],
            [999, mnrl_rich],
            [1000, mnrl_ultrarich]>>), kind_orange)
        Result.add (create {FINITE_PTABLE [INTEGER]}.make (<<
            [186, mnrl_ultrapoor],
            [569, mnrl_poor],
            [992, mnrl_abundant],
            [996, mnrl_rich],
            [1000, mnrl_ultrarich]>>), kind_red)
        Result.add (create {FINITE_PTABLE [INTEGER]}.make (<<
            [50, mnrl_ultrapoor],
            [160, mnrl_poor],
            [770, mnrl_abundant],
            [950, mnrl_rich],
            [1000, mnrl_ultrarich]>>), kind_brown)
    end

end -- class MAP_PROBABILITIES
