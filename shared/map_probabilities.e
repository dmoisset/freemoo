class MAP_PROBABILITIES
  -- Probabilistic Constants for Galaxy Generation

feature {NONE} -- Star constants

    average_star_kinds: ARRAY [TUPLE [INTEGER, INTEGER]] is
        -- Accumulative probability of a star being certain kind,
        -- in an average galaxy.
    once
        !!Result.make(1, 7)
        Result.put ([40, kind_blackhole], 1)
        Result.put ([145, kind_bluewhite], 2)
        Result.put ([290, kind_white], 3)
        Result.put ([426, kind_yellow], 4)
        Result.put ([570, kind_orange], 5)
        Result.put ([974, kind_red], 6)
        Result.put ([1000, kind_brown], 7)
    end

    orgrich_star_kinds: ARRAY [TUPLE [INTEGER, INTEGER]] is
        -- Accumulative probability of a star being certain kind,
        -- in an organic-rich galaxy.
    once
        !!Result.make (1, 7)
        Result.put ([70, kind_blackhole], 1)
        Result.put ([110, kind_bluewhite], 2)
        Result.put ([150, kind_white], 3)
        Result.put ([455, kind_yellow], 4)
        Result.put ([650, kind_orange], 5)
        Result.put ([977, kind_red], 6)
        Result.put ([1000, kind_brown], 7)
    end

    minrich_star_kinds: ARRAY [TUPLE [INTEGER, INTEGER]] is
        -- Accumulative probability of a star being a certain kind,
        -- in an mineral-rich galaxy.
    once
        !!Result.make (1, 7)
        Result.put ([30, kind_blackhole], 1)
        Result.put ([215, kind_bluewhite], 2)
        Result.put ([435, kind_white], 3)
        Result.put ([532, kind_yellow], 4)
        Result.put ([621, kind_orange], 5)
        Result.put ([993, kind_red], 6)
        Result.put ([1000, kind_brown], 7)
    end

    star_sizes: ARRAY [TUPLE [INTEGER, INTEGER]] is
        -- Accumulative probability of a star being a certain size.
    once
        !!Result.make (1, 3)
        Result.put ([290, stsize_big], 1)
        Result.put ([735, stsize_medium], 2)
        Result.put ([1000, stsize_small], 3)
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

    planet_types: ARRAY [TUPLE [INTEGER, INTEGER]] is
        -- planet type probability, indexed by type.  Independent
        -- of anything else
    once
        !!Result.make (1, 3)
        Result.put ([200, type_asteroids], 1)
        Result.put ([411, type_gasgiant], 2)
        Result.put ([1000, type_planet], 3)
    end

    average_climates: DICTIONARY [ ARRAY [TUPLE [INTEGER, INTEGER]], INTEGER] is
        -- Probability Dictionary of (planet probabilities of being a
        -- certain climate), indexed by star kind; for an average galaxy
    local
        dict: ARRAY [TUPLE [INTEGER, INTEGER]]
    once
        !!Result.make
         !!dict.make (1, 10)
         dict.add ([163, climate_toxic], 1)
         dict.add ([649, climate_radiated], 2)
         dict.add ([921, climate_barren], 3)
         dict.add ([990, climate_desert], 4)
         dict.add ([993, climate_tundra], 5)
         dict.add ([994, climate_ocean], 6)
         dict.add ([995, climate_swamp], 7)
         dict.add ([996, climate_arid], 8)
         dict.add ([998, climate_terran], 9)
         dict.add ([1000, climate_gaia], 10)
        Result.add (dict, kind_bluewhite) -- 422 Samples
         !!dict.make (1, 10)
         dict.put ([166, climate_toxic], 1)
         dict.put ([534, climate_radiated], 2)
         dict.put ([805, climate_barren], 3)
         dict.put ([865, climate_desert], 4)
         dict.put ([908, climate_tundra], 5)
         dict.put ([925, climate_ocean], 6)
         dict.put ([935, climate_swamp], 7)
         dict.put ([961, climate_arid], 8)
         dict.put ([993, climate_terran], 9)
         dict.put ([1000, climate_gaia], 10)
        Result.add (dict, kind_white) -- 468 Samples
         !!dict.make (1, 10)
         dict.put ([127, climate_toxic], 1)
         dict.put ([395, climate_radiated], 2)
         dict.put ([697, climate_barren], 3)
         dict.put ([756, climate_desert], 4)
         dict.put ([833, climate_tundra], 5)
         dict.put ([877, climate_ocean], 6)
         dict.put ([915, climate_swamp], 7)
         dict.put ([946, climate_arid], 8)
         dict.put ([988, climate_terran], 9)
         dict.put ([1000, climate_gaia], 10)
        Result.add (dict, kind_yellow) -- 612 Samples
         !!dict.make (1, 10)
         dict.put ([167, climate_toxic], 1)
         dict.put ([341, climate_radiated], 2)
         dict.put ([569, climate_barren], 3)
         dict.put ([651, climate_desert], 4)
         dict.put ([722, climate_tundra], 5)
         dict.put ([779, climate_ocean], 6)
         dict.put ([848, climate_swamp], 7)
         dict.put ([911, climate_arid], 8)
         dict.put ([986, climate_terran], 9)
         dict.put ([1000, climate_gaia], 10)
        Result.add (dict, kind_orange) -- 712 Samples
         !!dict.make (1, 10)
         dict.put ([162, climate_toxic], 1)
         dict.put ([291, climate_radiated], 2)
         dict.put ([788, climate_barren], 3)
         dict.put ([818, climate_desert], 4)
         dict.put ([884, climate_tundra], 5)
         dict.put ([906, climate_ocean], 6)
         dict.put ([929, climate_swamp], 7)
         dict.put ([954, climate_arid], 8)
         dict.put ([994, climate_terran], 9)
         dict.put ([1000, climate_gaia], 10)
        Result.add (dict, kind_red) -- 1087 Samples
         !!dict.make (1, 10)
         dict.put ([208, climate_toxic], 1)
         dict.put ([500, climate_radiated], 2)
         dict.put ([600, climate_barren], 3)
         dict.put ([800, climate_desert], 4)
         dict.put ([900, climate_tundra], 5)
         dict.put ([920, climate_ocean], 6)
         dict.put ([940, climate_swamp], 7)
         dict.put ([960, climate_arid], 8)
         dict.put ([990, climate_terran], 9)
         dict.put ([1000, climate_gaia], 10)
        Result.add (dict, kind_brown) -- 12 Samples
    end

    orgrich_climates: DICTIONARY [ARRAY [TUPLE [INTEGER, INTEGER]], INTEGER] is
        -- Probability Dictionary of (planet probabilities of being a
        -- certain climate), indexed by star kind; for an organic-rich galaxy
    local
        dict: ARRAY [TUPLE [INTEGER, INTEGER]]
    once
        !!Result.make
         !!dict.make (1, 10)
         dict.put ([130, climate_toxic], 1)
         dict.put ([500, climate_radiated], 2)
         dict.put ([722, climate_barren], 3)
         dict.put ([989, climate_desert], 4)
         dict.put ([995, climate_tundra], 5)
         dict.put ([996, climate_ocean], 6)
         dict.put ([997, climate_swamp], 7)
         dict.put ([998, climate_arid], 8)
         dict.put ([999, climate_terran], 9)
         dict.put ([1000, climate_gaia], 10)
        Result.add (dict, kind_bluewhite) -- 184 Samples
         !!dict.make (1, 10)
         dict.put ([71, climate_toxic], 1)
         dict.put ([326, climate_radiated], 2)
         dict.put ([532, climate_barren], 3)
         dict.put ([745, climate_desert], 4)
         dict.put ([808, climate_tundra], 5)
         dict.put ([830, climate_ocean], 6)
         dict.put ([865, climate_swamp], 7)
         dict.put ([929, climate_arid], 8)
         dict.put ([993, climate_terran], 9)
         dict.put ([1000, climate_gaia], 10)
        Result.add (dict, kind_white) -- 141 Samples
         !!dict.make (1, 10)
         dict.put ([88, climate_toxic], 1)
         dict.put ([263, climate_radiated], 2)
         dict.put ([439, climate_barren], 3)
         dict.put ([598, climate_desert], 4)
         dict.put ([736, climate_tundra], 5)
         dict.put ([800, climate_ocean], 6)
         dict.put ([858, climate_swamp], 7)
         dict.put ([920, climate_arid], 8)
         dict.put ([980, climate_terran], 9)
         dict.put ([1000, climate_gaia], 10)
        Result.add (dict, kind_yellow) -- 1346 Samples
         !!dict.make (1, 10)
         dict.put ([70, climate_toxic], 1)
         dict.put ([177, climate_radiated], 2)
         dict.put ([327, climate_barren], 3)
         dict.put ([446, climate_desert], 4)
         dict.put ([619, climate_tundra], 5)
         dict.put ([711, climate_ocean], 6)
         dict.put ([790, climate_swamp], 7)
         dict.put ([890, climate_arid], 8)
         dict.put ([971, climate_terran], 9)
         dict.put ([1000, climate_gaia], 10)
        Result.add (dict, kind_orange) -- 1022 Samples
         !!dict.make (1, 10)
         dict.put ([128, climate_toxic], 1)
         dict.put ([194, climate_radiated], 2)
         dict.put ([564, climate_barren], 3)
         dict.put ([628, climate_desert], 4)
         dict.put ([864, climate_tundra], 5)
         dict.put ([900, climate_ocean], 6)
         dict.put ([932, climate_swamp], 7)
         dict.put ([964, climate_arid], 8)
         dict.put ([999, climate_terran], 9)
         dict.put ([1000, climate_gaia], 10)
        Result.add (dict, kind_red) -- 872 Samples
         !!dict.make (1, 10)
         dict.put ([200, climate_toxic], 1)
         dict.put ([500, climate_radiated], 2)
         dict.put ([600, climate_barren], 3)
         dict.put ([800, climate_desert], 4)
         dict.put ([900, climate_tundra], 5)
         dict.put ([920, climate_ocean], 6)
         dict.put ([940, climate_swamp], 7)
         dict.put ([960, climate_arid], 8)
         dict.put ([990, climate_terran], 9)
         dict.put ([1000, climate_gaia], 10)
        Result.add (dict, kind_brown) -- 10 Samples
    end
    minrich_climates: DICTIONARY [ARRAY [TUPLE [INTEGER, INTEGER]], INTEGER] is
        -- Probability Dictionary of (planet probabilities of being a
        -- certain climate), indexed by star kind; for an mineral-rich galaxy
    local
        dict: ARRAY [TUPLE [INTEGER, INTEGER]]
    once
        !!Result.make
         !!dict.make (1, 10)
         dict.put ([129, climate_toxic], 1)
         dict.put ([671, climate_radiated], 2)
         dict.put ([931, climate_barren], 3)
         dict.put ([988, climate_desert], 4)
         dict.put ([995, climate_tundra], 5)
         dict.put ([996, climate_ocean], 6)
         dict.put ([997, climate_swamp], 7)
         dict.put ([998, climate_arid], 8)
         dict.put ([999, climate_terran], 9)
         dict.put ([1000, climate_gaia], 10)
        Result.add (dict, kind_bluewhite) -- 770 Samples
         !!dict.make (1, 10)
         dict.put ([132, climate_toxic], 1)
         dict.put ([471, climate_radiated], 2)
         dict.put ([816, climate_barren], 3)
         dict.put ([866, climate_desert], 4)
         dict.put ([911, climate_tundra], 5)
         dict.put ([931, climate_ocean], 6)
         dict.put ([953, climate_swamp], 7)
         dict.put ([967, climate_arid], 8)
         dict.put ([997, climate_terran], 9)
         dict.put ([1000, climate_gaia], 10)
        Result.add (dict, kind_white) -- 703 Samples
         !!dict.make (1, 10)
         dict.put ([135, climate_toxic], 1)
         dict.put ([365, climate_radiated], 2)
         dict.put ([674, climate_barren], 3)
         dict.put ([741, climate_desert], 4)
         dict.put ([811, climate_tundra], 5)
         dict.put ([860, climate_ocean], 6)
         dict.put ([890, climate_swamp], 7)
         dict.put ([930, climate_arid], 8)
         dict.put ([993, climate_terran], 9)
         dict.put ([1000, climate_gaia], 10)
        Result.add (dict, kind_yellow) -- 430 Samples
         !!dict.make (1, 10)
         dict.put ([117, climate_toxic], 1)
         dict.put ([292, climate_radiated], 2)
         dict.put ([582, climate_barren], 3)
         dict.put ([638, climate_desert],4 )
         dict.put ([738, climate_tundra], 5)
         dict.put ([781, climate_ocean], 6)
         dict.put ([842, climate_swamp], 7)
         dict.put ([903, climate_arid], 8)
         dict.put ([980, climate_terran], 9)
         dict.put ([1000, climate_gaia], 10)
        Result.add (dict, kind_orange) -- 462 Samples
         !!dict.make (1, 10)
         dict.put ([174, climate_toxic], 1)
         dict.put ([314, climate_radiated], 2)
         dict.put ([766, climate_barren], 3)
         dict.put ([807, climate_desert], 4)
         dict.put ([894, climate_tundra], 5)
         dict.put ([922, climate_ocean], 6)
         dict.put ([942, climate_swamp], 7)
         dict.put ([960, climate_arid], 8)
         dict.put ([997, climate_terran], 9)
         dict.put ([1000, climate_gaia], 10)
        Result.add (dict, kind_red) -- 967 Samples
         !!dict.make (1, 10)
         dict.put ([208, climate_toxic], 1)
         dict.put ([500, climate_radiated], 2)
         dict.put ([600, climate_barren], 3)
         dict.put ([800, climate_desert], 4)
         dict.put ([900, climate_tundra], 5)
         dict.put ([920, climate_ocean], 6)
         dict.put ([940, climate_swamp], 7)
         dict.put ([960, climate_arid], 8)
         dict.put ([990, climate_terran], 9)
         dict.put ([1000, climate_gaia], 10)
        Result.add (dict, kind_brown) -- 0 Samples
    end

    planet_sizes: ARRAY [TUPLE [INTEGER, INTEGER]] is
        -- Accumulated probability for a planet being a certain size.
        -- Independent of star-kinds and galaxy ages
    once
        !!Result.make (1, 5)
        Result.put ([100, plsize_tiny], 1)
        Result.put ([293, plsize_small], 2)
        Result.put ([704, plsize_medium], 3)
        Result.put ([904, plsize_large], 4)
        Result.put ([1000, plsize_huge], 5)
    end


    planet_gravs: DICTIONARY [ARRAY [TUPLE [INTEGER, INTEGER]], INTEGER] is
        -- Planet Gravity probabilities, indexed by star kind
    local
        dict: ARRAY [TUPLE[INTEGER, INTEGER]]
    once
        !!Result.make
        !!dict.make (1, 3)
        dict.put ([42, grav_lowg], 1)
        dict.put ([711, grav_normalg], 2)
        dict.put ([1000, grav_highg], 3)
        Result.add (dict, kind_bluewhite)
        !!dict.make (1, 3)
        dict.put ([106, grav_lowg], 1)
        dict.put ([807, grav_normalg], 2)
        dict.put ([1000, grav_highg], 3)
        Result.add (dict, kind_white)
        !!dict.make (1, 3)
        dict.put ([138, grav_lowg], 1)
        dict.put ([841, grav_normalg], 2)
        dict.put ([1000, grav_highg], 3)
        Result.add (dict, kind_yellow)
        !!dict.make (1, 3)
        dict.put ([221, grav_lowg], 1)
        dict.put ([933, grav_normalg], 2)
        dict.put ([1000, grav_highg], 3)
        Result.add (dict, kind_orange)
        !!dict.make (1, 3)
        dict.put ([296, grav_lowg], 1)
        dict.put ([958, grav_normalg], 2)
        dict.put ([1000, grav_highg], 3)
        Result.add (dict, kind_red)
        !!dict.make (1, 3)
        dict.put ([136, grav_lowg], 1)
        dict.put ([909, grav_normalg], 2)
        dict.put ([1000, grav_highg], 3)
        Result.add (dict, kind_brown)
    end

    planet_minerals: DICTIONARY[ ARRAY[ TUPLE [INTEGER, INTEGER]], INTEGER] is
        -- planet Mineral richness, indexed by star kind
    local
        dict: ARRAY [TUPLE [INTEGER, INTEGER]]
    once
        !!Result.make
         !!dict.make (1, 5)
         dict.put ([1, mnrl_ultrapoor], 1)
         dict.put ([2, mnrl_poor], 2)
         dict.put ([399, mnrl_abundant], 3)
         dict.put ([815, mnrl_rich], 4)
         dict.put ([1000, mnrl_ultrarich], 5)
        Result.add (dict, kind_bluewhite)
         !!dict.make (1, 5)
         dict.put ([1, mnrl_ultrapoor], 1)
         dict.put ([196, mnrl_poor], 2)
         dict.put ([608, mnrl_abundant], 3)
         dict.put ([902, mnrl_rich], 4)
         dict.put ([1000, mnrl_ultrarich], 5)
        Result.add (dict, kind_white)
         !!dict.make (1, 5)
         dict.put ([1, mnrl_ultrapoor], 1)
         dict.put ([304, mnrl_poor], 2)
         dict.put ([708, mnrl_abundant], 3)
         dict.put ([915, mnrl_rich], 4)
         dict.put ([1000, mnrl_ultrarich], 5)
        Result.add (dict, kind_yellow)
         !!dict.make (1, 5)
         dict.put ([104, mnrl_ultrapoor], 1)
         dict.put ([506, mnrl_poor], 2)
         dict.put ([896, mnrl_abundant], 3)
         dict.put ([999, mnrl_rich], 4)
         dict.put ([1000, mnrl_ultrarich], 5)
        Result.add (dict, kind_orange)
         !!dict.make (1, 5)
         dict.put ([186, mnrl_ultrapoor], 1)
         dict.put ([569, mnrl_poor], 2)
         dict.put ([992, mnrl_abundant], 3)
         dict.put ([996, mnrl_rich], 4)
         dict.put ([1000, mnrl_ultrarich], 5)
        Result.add (dict, kind_red)
         !!dict.make (1, 5)
         dict.put ([50, mnrl_ultrapoor], 1)
         dict.put ([160, mnrl_poor], 2)
         dict.put ([770, mnrl_abundant], 3)
         dict.put ([950, mnrl_rich], 4)
         dict.put ([1000, mnrl_ultrarich], 5)
        Result.add (dict, kind_brown)
    end


end -- class MAP_PROBABILITIES
