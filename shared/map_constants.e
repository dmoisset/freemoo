class MAP_CONSTANTS
    -- galactic enumerations and constants

feature -- Constants

    kind_blackhole, kind_bluewhite, kind_white, kind_yellow,
    kind_orange, kind_red, kind_brown: INTEGER is unique
        -- Possible values for a star's `kind'

    kind_min: INTEGER is
        -- Minimum value for a star's `kind'
    once
        Result := kind_blackhole
    end

    kind_max: INTEGER is
        -- Maximum value for a star's `kind'
    once
        Result := kind_brown
    end

    kind_names: DICTIONARY[STRING, INTEGER] is
    once
        !!Result.make
        Result.add ("Black Hole", kind_blackhole)
        Result.add ("Blue-White", kind_bluewhite)
        Result.add ("Orange", kind_orange)
        Result.add ("Red", kind_red)
        Result.add ("White", kind_white)
        Result.add ("Brown", kind_brown)
        Result.add ("Yellow", kind_yellow)
    end

    stspecial_nospecial, stspecial_wormhole, stspecial_debris,
    stspecial_piratecache, stspecial_hero,
    stspecial_orion: INTEGER is unique
        -- Possible values for a stars's `special'

    stspecial_min: INTEGER is
        -- Minimum value for a star's `special'
    once
        Result := stspecial_nospecial
    end

    stspecial_max: INTEGER is
        -- Maximum value for a star's `special'
    once
        Result := stspecial_orion
    end

    stsize_small, stsize_medium, stsize_big: INTEGER is unique
        -- Possible values for a star's `size'

    stsize_min: INTEGER is
        -- Minimum value for a star's `size'
    once
        Result := stsize_small
    end

    stsize_max: INTEGER is
        -- Maximum value for a star's `size'
    once
        Result := stsize_big
    end

    stsize_names: DICTIONARY[STRING, INTEGER] is
    once
        !!Result.make
        Result.add ("Big", stsize_big)
        Result.add ("Medium", stsize_medium)
        Result.add ("Small", stsize_small)
    end

    plsize_tiny, plsize_small, plsize_medium, plsize_large,
    plsize_huge: INTEGER is unique
        -- Possible values for a planet's `size'

    plsize_min: INTEGER is
        -- Minimum value for a planet's `size'
    once
        Result := plsize_tiny
    end

    plsize_max: INTEGER is
        -- Maximum value for a planet's `size'
    once
        Result := plsize_huge
    end

    plsize_names: DICTIONARY[STRING, INTEGER] is
    once
        !!Result.make
        Result.add ("Tiny", plsize_tiny)
        Result.add ("Small", plsize_small)
        Result.add ("Medium", plsize_medium)
        Result.add ("Large", plsize_large)
        Result.add ("Huge", plsize_huge)
    end

    climate_toxic, climate_radiated, climate_barren, climate_desert,
    climate_tundra, climate_ocean, climate_swamp, climate_arid,
    climate_terran, climate_gaia: INTEGER is unique
        -- Possible values for a planet's `climate'

    climate_min: INTEGER is
        -- Minimum value for a planet's `climate'
    once
        Result := climate_toxic
    end

    climate_max: INTEGER is
        -- Maximum value for a planet's `climate'
    once
        Result := climate_gaia
    end

    climate_names: DICTIONARY[STRING, INTEGER] is
    once
        !!Result.make
        Result.add ("Toxic", climate_toxic)
        Result.add ("Radiated", climate_radiated)
        Result.add ("Barren", climate_barren)
        Result.add ("Desert", climate_desert)
        Result.add ("Tundra", climate_tundra)
        Result.add ("Ocean", climate_ocean)
        Result.add ("Swamp", climate_swamp)
        Result.add ("Arid", climate_arid)
        Result.add ("Terran", climate_terran)
        Result.add ("Gaia", climate_gaia)
    end

    mnrl_ultrapoor, mnrl_poor, mnrl_abundant,
    mnrl_rich, mnrl_ultrarich: INTEGER is unique
        -- Possible values for a planet's `mineral'

    mnrl_min: INTEGER is
        -- Minimum value for a planet's `mineral'
    once
        Result := mnrl_ultrapoor
    end

    mnrl_max: INTEGER is
        -- Maximum value for a planet's `mineral'
    once
        Result := mnrl_ultrarich
    end

    mineral_names: DICTIONARY[STRING, INTEGER] is
    once
        !!Result.make
        Result.add ("Ultra Poor", mnrl_ultrapoor)
        Result.add ("Poor", mnrl_poor)
        Result.add ("Abundant", mnrl_abundant)
        Result.add ("Rich", mnrl_rich)
        Result.add ("Ultra Rich", mnrl_ultrarich)
    end


    type_asteroids, type_gasgiant, type_planet: INTEGER is unique
        -- Possible values for a planet's `type'

    type_min: INTEGER is
        -- Minimum value for a planet's `type'
    once
        Result := type_asteroids
    end

    type_max: INTEGER is
        -- Maximum value for a planet's `type'
    once
        Result := type_planet
    end

    type_names: DICTIONARY[STRING, INTEGER] is
    once
        !!Result.make
        Result.add ("Planet", type_planet)
        Result.add ("Gas Giant", type_gasgiant)
        Result.add ("Asteroid Field", type_asteroids)
    end


    grav_lowg, grav_normalg, grav_highg: INTEGER is unique
        -- Possible values for a planet's `grav'

    grav_min: INTEGER is
        -- Minimum value for a planet's `grav'
    once
        Result := grav_lowg
    end

    grav_max: INTEGER is
        -- Maximum value for a planet's `grav'
    once
        Result := grav_highg
    end

    gravity_names: DICTIONARY[STRING, INTEGER] is
    once
        !!Result.make
        Result.add ("LG", grav_lowg)
        Result.add ("", grav_normalg)
        Result.add ("HG", grav_highg)
    end


    plspecial_nospecial, plspecial_gold, plspecial_gems, plspecial_natives,
    plspecial_splinter, plspecial_artifacts: INTEGER is unique
        -- Possible values for a planet's `special'

    plspecial_min: INTEGER is
        -- Minimum value for a planet's `special'
    once
        Result := plspecial_nospecial
    end

    plspecial_max: INTEGER is
        -- Maximum value for a planet's `special'
    once
        Result := plspecial_artifacts
    end

end