class MAP_GENERATOR_V1

inherit
    MAP_GENERATOR
        redefine
            make;
    MAP_CONSTANTS

creation
    make

feature{NONE} -- Position Generation
    mapmethod_one: ARRAY[COORDS] is
    local
        i: INTEGER
        newc: COORDS
    do
        !!Result.make (1, 0)
-- First toss in stars anywhere
        from
        until
            Result.count = starcount
        loop
            newc := newcoords
            Result.add_last(newc)
        end

-- Then remove any buch-up
        from
            i := Result.lower
        until
            i > Result.upper
        loop
            if bunched_up (Result.item (i), Result) then
                Result.remove (i)
            else
                i := i + 1
            end
        end

-- Then add in more to complete (carefully now)
        fill_carefully (Result)

-- Then remove any lone-ranger
        from
            i := Result.lower
        until
            i > Result.upper
        loop
            if too_far_away(Result.item(i), Result) then
                Result.remove(i)
            else
                i := i + 1
            end
        end

-- Finally top up (carefully) and serve cold
        fill_carefully(Result)
    ensure
        Result.count = starcount
    end

    fill_carefully(res:ARRAY[COORDS]) is
    local
        newc: COORDS
    do
        from
        until
            res.count = starcount
        loop
            from
                newc := newcoords
            until
                goodstar (newc, res)
            loop
                newc := newcoords
            end
            res.add_last(newc)
        end
    ensure
        res.count = starcount
    end



    mapmethod_two: ARRAY[COORDS] is
    do
        !!Result.make (1, 0)
        fill_carefully (Result)
    ensure
        Result.count = starcount
    end



    bunched_up (this: COORDS; here: ARRAY[COORDS]): BOOLEAN is
        -- true if closer than mindelta to another star
    local
        j: INTEGER
    do
        from
            j := here.lower
        until
            j > here.upper or Result
        loop
            if here.item(j) /= this and then ((here.item(j) |-| this) < mindelta) then
                Result := true
            end
            j := j + 1
        end
    end

    too_far_away (this: COORDS; here: ARRAY[COORDS]): BOOLEAN is
        -- true if this' nearest neighbour is farther than maxdelta away
    local
        j: INTEGER
        farthest: REAL
    do
        from
            j := here.lower
            farthest := maxdelta + 1
        until
            j > here.upper
        loop
            if this /= here.item(j) then
                farthest := farthest.min(this |-| here.item(j))
            end
            j := j + 1
        end
        Result := (farthest > maxdelta) and not here.is_empty
    end


    goodstar (this: COORDS; here: ARRAY[COORDS]): BOOLEAN is
        -- Optimization for not_bunched and too_far_away, goes over
        -- the structure only once
    local
        i: INTEGER
        farthest: REAL
    do
        Result := true
        farthest := maxdelta + 1
        from
            i := here.lower
        until
            i > here.upper or not Result
        loop
            if (this |-| here.item (i)) < mindelta then
                Result := false
            end
            farthest := farthest.min (this |-| here.item (i))
            i := i + 1
        end
        if farthest > maxdelta and not here.is_empty then
            Result := false
        end
    ensure
        Result = not (bunched_up (this, here) or too_far_away (this, here))
    end


    newcoords: COORDS is
      -- Random Coords within limits
    local
        xx, yy: REAL
    do
        rand.next
        xx := rand.last_real * limit.x
        rand.next
        yy := rand.last_real * limit.y
        !!Result.make_at(xx, yy)
    ensure
        Result /= Void
    end


feature {NONE} -- Name Generation
    generate_names: ARRAY[STRING] is
    local
        file: TEXT_FILE_READ
        index: INTEGER
        buffer: ARRAY[STRING]
    do
        !!Result.with_capacity (starcount, 1)
        !!buffer.make (1, 0)
        from
            !!file.connect_to("../../data/starnames.txt")
        until
            file.end_of_input
        loop
            file.read_line
            buffer.add_last (clone(file.last_string))
        end
        from
        until
            Result.count = starcount
        loop
            rand.next
            index := rand.last_integer (831) + 13
            if not Result.has (buffer.item (index)) then
                Result.add_last(buffer.item (index))
            end
        end
        file.disconnect
    end

feature {NONE} -- Planet Generation
    make_planets_on (star: STAR) is
    local
        i: INTEGER
        planet: PLANET
    do
        from
            i := 1
        until
            i > 5
        loop
            rand.next
            if rand.last_integer (100) <= planet_prob.at (star.kind) then
                !!planet.make (star, one_of (planet_sizes),
                one_of (planet_climates.at (star.kind)),
                one_of (planet_minerals.at (star.kind)),
                one_of (planet_gravs.at (star.kind)),
                one_of (planet_types), plspecial_nospecial)
                star.set_planet (planet, i)
            end
            i := i + 1
        end
    end

feature {NONE} -- Orion placing
    place_orion (starlist: ARRAY[STAR]) is
    local
        index: INTEGER
        orion: PLANET
    do
        index := closest_star_to_or_within (center, 80, starlist)
        !!orion.make (starlist.item (index), plsize_huge, climate_gaia,
                      mnrl_ultrarich, grav_normalg, type_planet,
                      plspecial_nospecial)
        rand.next
        starlist.item (index).set_planet (orion, rand.last_integer (5))
        starlist.item (index).set_special (stspecial_orion)
        starlist.item (index).set_name ("Orion")
        dont_touch.add (index)
    end

feature{NONE} -- Internal

    one_of (probs: DICTIONARY[INTEGER, INTEGER]):INTEGER is
     -- Choose a random entry of probs.
     -- values of probs contain probability of choosing i or less
     -- (in thousandths)
     -- If probs contains values > 1000 or repeated values, it's your guess.
    require
        probs /= Void
        total_prob_of_1: probs.occurrences (1000) = 1
    local
        curs: ITERATOR[INTEGER]
        choice: INTEGER
    do
        rand.next
        choice := rand.last_integer (1000)
        curs := probs.get_new_iterator_on_keys
        from
            curs.start
            Result := probs.key_at(1000)
        until
            curs.is_off
        loop
            if (probs @ curs.item).in_range(choice, probs @ Result) then
                Result := curs.item
            end
            curs.next
        end
    end

    closest_star_to (c: COORDS; starlist: ARRAY[STAR]): INTEGER is
    require
        c /= Void
    local
        curs: INTEGER
        dist: REAL
    do
        dist := Maximum_real
        from
            curs := starlist.lower
        until
            curs > starlist.upper
        loop
            if starlist.item (curs) /= Void and then (starlist.item (curs) |-| c) <= dist then
                dist := starlist.item (curs) |-| c
                Result := curs
            end
            curs := curs + 1
        end
    end

    closest_star_to_or_within (c: COORDS; threshold: INTEGER; starlist: ARRAY[STAR]): INTEGER is
    require
        c /= Void
    local
        curs: INTEGER
        dist: REAL
    do
        dist := Maximum_real
        from
            curs := starlist.lower
        until
            curs > starlist.upper or dist < threshold
        loop
            if starlist.item (curs) /= Void and then (starlist.item (curs) |-| c) <= dist then
                dist := starlist.item (curs) |-| c
                Result := curs
            end
            curs := curs + 1
        end
    end

feature -- Operation
    generate (galaxy: GALAXY; players: PLAYER_LIST [PLAYER]) is
    local
        starposs: ARRAY[COORDS]
        starnams: ARRAY[STRING]
        starlist: ARRAY[STAR]
        i: INTEGER
        newstar: STAR
        planets: ARRAY[PLANET]
    do
        !!planets.make(1,0)
        !!starlist.make(1,0)
        print("Generating Positions%N")
        starposs := mapmethod_one
        print("Generating Names%N")
        starnams := generate_names
        print("Generating Planets%N")
        from
            i := starposs.lower
        until
            i > starposs.upper
        loop
            rand.next
            !!newstar.make(starposs @ i, starnams @ i, one_of (star_kinds), one_of (star_sizes))
            make_planets_on (newstar)
            starlist.add_last(newstar)
            i := i + 1
        end
        print("Placing Orion%N")
        place_orion (starlist)
        galaxy.set_stars (starlist)
        !!homeworlds.make (1, players.count)
    end


feature{NONE} -- Creation
    make (options: OPTION_LIST) is
    require
        options /= Void
    local
        c:COORDS
    do
        size := options.enum_options_names @ "galaxysize"
        galage := options.enum_options_names @ "galaxyage"
        !!dont_touch.make

        if size.is_equal("small") then
            !!c.make_at (200, 147)
            !!center.make_at (100, 74)
            starcount := 20
        elseif size.is_equal("medium") then
            !!c.make_at (270, 190)
            !!center.make_at (135, 95)
            starcount := 36
        elseif size.is_equal("large") then
            !!c.make_at (330, 230)
            !!center.make_at (165, 115)
            starcount := 54
        elseif size.is_equal("huge") then
            !!c.make_at (380, 270)
            !!center.make_at (190, 135)
            starcount := 71
        end
        if galage.is_equal("average") then
            star_kinds := average_star_kinds
            planet_climates := average_climates
        elseif galage.is_equal("organicrich") then
            star_kinds := orgrich_star_kinds
            planet_climates := orgrich_climates
        elseif galage.is_equal("mineralrich") then
            star_kinds := minrich_star_kinds
            planet_climates := minrich_climates
        end
        !!limit
        limit.project (c)
    end




feature {NONE} -- Implementation
    rand: STD_RAND is
        -- Random number generator, used all over
    local
        seed: J_TIMER
    once
        !!seed
        !!Result.with_seed (seed.ticks)
    end

    size: STRING
        -- "small", "medium", "large" or "huge"

    galage: STRING
        -- "average", "organicrich" or "mineralrich"

    starcount: INTEGER
        -- Number of stars in galaxy, depends of size

    star_kinds: DICTIONARY[INTEGER, INTEGER]
        -- Accumulative probability of a star being certain kind.
        -- One of average_star_kinds, orgrich_star_kinds or minrich_star_kinds

    planet_climates: DICTIONARY[DICTIONARY[INTEGER, INTEGER], INTEGER]
        -- Probability for a star having a certain climate, indexed by
        -- star kind.  One of average_climates, orgrich_climates or
        -- minrich_climates

    limit: PROJECTION
        -- Projection of the outermost posible point in galaxy

    center: COORDS
        -- Center of the galaxy

    dont_touch: SET[INTEGER]
        -- Stars that souldn't be modified any more, thank you.

feature{NONE} -- Internal Constants

    average_star_kinds: DICTIONARY[INTEGER, INTEGER] is
        -- Accumulative probability of a star being certain kind,
        -- in an average galaxy.
    once
        !!Result.make
        Result.add (40, kind_blackhole)
        Result.add (145, kind_bluewhite)
        Result.add (290, kind_white)
        Result.add (426, kind_yellow)
        Result.add (570, kind_orange)
        Result.add (974, kind_red)
        Result.add (1000, kind_brown)
    end

    orgrich_star_kinds: DICTIONARY[INTEGER, INTEGER] is
        -- Accumulative probability of a star being certain kind,
        -- in an organic-rich galaxy.
    once
        !!Result.make
        Result.add (70, kind_blackhole)
        Result.add (110, kind_bluewhite)
        Result.add (150, kind_white)
        Result.add (455, kind_yellow)
        Result.add (650, kind_orange)
        Result.add (977, kind_red)
        Result.add (1000, kind_brown)
    end

    minrich_star_kinds: DICTIONARY[INTEGER, INTEGER] is
        -- Accumulative probability of a star being a certain kind,
        -- in an mineral-rich galaxy.
    once
        !!Result.make
        Result.add (30, kind_blackhole)
        Result.add (215, kind_bluewhite)
        Result.add (435, kind_white)
        Result.add (532, kind_yellow)
        Result.add (621, kind_orange)
        Result.add (993, kind_red)
        Result.add (1000, kind_brown)
    end

    star_sizes: DICTIONARY[INTEGER, INTEGER] is
        -- Accumulative probability of a star being a certain size.
    once
        !!Result.make
        Result.add (290, stsize_big)
        Result.add (735, stsize_medium)
        Result.add (1000, stsize_small)
    end

-----------------------------------------------------------
-- Planet constants:  Still few samples for brown stars  --
-----------------------------------------------------------

    planet_prob: DICTIONARY[INTEGER, INTEGER] is
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

    planet_types: DICTIONARY[INTEGER, INTEGER] is
       -- planet type probability, indexed by type.  Independent
       -- of anything else
    once
        !!Result.make
        Result.add (200, type_asteroids)
        Result.add (411, type_gasgiant)
        Result.add (1000, type_planet)
    end

    average_climates: DICTIONARY [DICTIONARY [INTEGER, INTEGER], INTEGER] is
        -- Probability Dictionary of (planet probabilities of being a
        -- certain climate), indexed by star kind; for an average galaxy
    local
        dict: DICTIONARY[INTEGER, INTEGER]
    once
        !!Result.make
         !!dict.make
         dict.add (163, climate_toxic)
         dict.add (649, climate_radiated)
         dict.add (921, climate_barren)
         dict.add (990, climate_desert)
         dict.add (993, climate_tundra)
         dict.add (994, climate_ocean)
         dict.add (995, climate_swamp)
         dict.add (996, climate_arid)
         dict.add (998, climate_terran)
         dict.add (1000, climate_gaia)
        Result.add (dict, kind_bluewhite) -- 422 Samples
         !!dict.make
         dict.add (166, climate_toxic)
         dict.add (534, climate_radiated)
         dict.add (805, climate_barren)
         dict.add (865, climate_desert)
         dict.add (908, climate_tundra)
         dict.add (925, climate_ocean)
         dict.add (935, climate_swamp)
         dict.add (961, climate_arid)
         dict.add (993, climate_terran)
         dict.add (1000, climate_gaia)
        Result.add (dict, kind_white) -- 468 Samples
         !!dict.make
         dict.add (127, climate_toxic)
         dict.add (395, climate_radiated)
         dict.add (697, climate_barren)
         dict.add (756, climate_desert)
         dict.add (833, climate_tundra)
         dict.add (877, climate_ocean)
         dict.add (915, climate_swamp)
         dict.add (946, climate_arid)
         dict.add (988, climate_terran)
         dict.add (1000, climate_gaia)
        Result.add (dict, kind_yellow) -- 612 Samples
         !!dict.make
         dict.add (167, climate_toxic)
         dict.add (341, climate_radiated)
         dict.add (569, climate_barren)
         dict.add (651, climate_desert)
         dict.add (722, climate_tundra)
         dict.add (779, climate_ocean)
         dict.add (848, climate_swamp)
         dict.add (911, climate_arid)
         dict.add (986, climate_terran)
         dict.add (1000, climate_gaia)
        Result.add (dict, kind_orange) -- 712 Samples
         !!dict.make
         dict.add (162, climate_toxic)
         dict.add (291, climate_radiated)
         dict.add (788, climate_barren)
         dict.add (818, climate_desert)
         dict.add (884, climate_tundra)
         dict.add (906, climate_ocean)
         dict.add (929, climate_swamp)
         dict.add (954, climate_arid)
         dict.add (994, climate_terran)
         dict.add (1000, climate_gaia)
        Result.add (dict, kind_red) -- 1087 Samples
         !!dict.make
         dict.add (208, climate_toxic)
         dict.add (500, climate_radiated)
         dict.add (600, climate_barren)
         dict.add (800, climate_desert)
         dict.add (900, climate_tundra)
         dict.add (920, climate_ocean)
         dict.add (940, climate_swamp)
         dict.add (960, climate_arid)
         dict.add (990, climate_terran)
         dict.add (1000, climate_gaia)
        Result.add (dict, kind_brown) -- 12 Samples
    end

    orgrich_climates: DICTIONARY [DICTIONARY [INTEGER, INTEGER], INTEGER] is
        -- Probability Dictionary of (planet probabilities of being a
        -- certain climate), indexed by star kind; for an organic-rich galaxy
    local
        dict: DICTIONARY[INTEGER, INTEGER]
    once
        !!Result.make
         !!dict.make
         dict.add (130, climate_toxic)
         dict.add (500, climate_radiated)
         dict.add (722, climate_barren)
         dict.add (989, climate_desert)
         dict.add (995, climate_tundra)
         dict.add (996, climate_ocean)
         dict.add (997, climate_swamp)
         dict.add (998, climate_arid)
         dict.add (999, climate_terran)
         dict.add (1000, climate_gaia)
        Result.add (dict, kind_bluewhite) -- 184 Samples
         !!dict.make
         dict.add (71, climate_toxic)
         dict.add (326, climate_radiated)
         dict.add (532, climate_barren)
         dict.add (745, climate_desert)
         dict.add (808, climate_tundra)
         dict.add (830, climate_ocean)
         dict.add (865, climate_swamp)
         dict.add (929, climate_arid)
         dict.add (993, climate_terran)
         dict.add (1000, climate_gaia)
        Result.add (dict, kind_white) -- 141 Samples
         !!dict.make
         dict.add (88, climate_toxic)
         dict.add (263, climate_radiated)
         dict.add (439, climate_barren)
         dict.add (598, climate_desert)
         dict.add (736, climate_tundra)
         dict.add (800, climate_ocean)
         dict.add (858, climate_swamp)
         dict.add (920, climate_arid)
         dict.add (980, climate_terran)
         dict.add (1000, climate_gaia)
        Result.add (dict, kind_yellow) -- 1346 Samples
         !!dict.make
         dict.add (70, climate_toxic)
         dict.add (177, climate_radiated)
         dict.add (327, climate_barren)
         dict.add (446, climate_desert)
         dict.add (619, climate_tundra)
         dict.add (711, climate_ocean)
         dict.add (790, climate_swamp)
         dict.add (890, climate_arid)
         dict.add (971, climate_terran)
         dict.add (1000, climate_gaia)
        Result.add (dict, kind_orange) -- 1022 Samples
         !!dict.make
         dict.add (128, climate_toxic)
         dict.add (194, climate_radiated)
         dict.add (564, climate_barren)
         dict.add (628, climate_desert)
         dict.add (864, climate_tundra)
         dict.add (900, climate_ocean)
         dict.add (932, climate_swamp)
         dict.add (964, climate_arid)
         dict.add (999, climate_terran)
         dict.add (1000, climate_gaia)
        Result.add (dict, kind_red) -- 872 Samples
         !!dict.make
         dict.add (200, climate_toxic)
         dict.add (500, climate_radiated)
         dict.add (600, climate_barren)
         dict.add (800, climate_desert)
         dict.add (900, climate_tundra)
         dict.add (920, climate_ocean)
         dict.add (940, climate_swamp)
         dict.add (960, climate_arid)
         dict.add (990, climate_terran)
         dict.add (1000, climate_gaia)
        Result.add (dict, kind_brown) -- 10 Samples
    end

    minrich_climates: DICTIONARY [DICTIONARY [INTEGER, INTEGER], INTEGER] is
        -- Probability Dictionary of (planet probabilities of being a
        -- certain climate), indexed by star kind; for an mineral-rich galaxy
    local
        dict: DICTIONARY[INTEGER, INTEGER]
    once
        !!Result.make
         !!dict.make
         dict.add (129, climate_toxic)
         dict.add (671, climate_radiated)
         dict.add (931, climate_barren)
         dict.add (988, climate_desert)
         dict.add (995, climate_tundra)
         dict.add (996, climate_ocean)
         dict.add (997, climate_swamp)
         dict.add (998, climate_arid)
         dict.add (999, climate_terran)
         dict.add (1000, climate_gaia)
        Result.add (dict, kind_bluewhite) -- 770 Samples
         !!dict.make
         dict.add (132, climate_toxic)
         dict.add (471, climate_radiated)
         dict.add (816, climate_barren)
         dict.add (866, climate_desert)
         dict.add (911, climate_tundra)
         dict.add (931, climate_ocean)
         dict.add (953, climate_swamp)
         dict.add (967, climate_arid)
         dict.add (997, climate_terran)
         dict.add (1000, climate_gaia)
        Result.add (dict, kind_white) -- 703 Samples
         !!dict.make
         dict.add (135, climate_toxic)
         dict.add (365, climate_radiated)
         dict.add (674, climate_barren)
         dict.add (741, climate_desert)
         dict.add (811, climate_tundra)
         dict.add (860, climate_ocean)
         dict.add (890, climate_swamp)
         dict.add (930, climate_arid)
         dict.add (993, climate_terran)
         dict.add (1000, climate_gaia)
        Result.add (dict, kind_yellow) -- 430 Samples
         !!dict.make
         dict.add (117, climate_toxic)
         dict.add (292, climate_radiated)
         dict.add (582, climate_barren)
         dict.add (638, climate_desert)
         dict.add (738, climate_tundra)
         dict.add (781, climate_ocean)
         dict.add (842, climate_swamp)
         dict.add (903, climate_arid)
         dict.add (980, climate_terran)
         dict.add (1000, climate_gaia)
        Result.add (dict, kind_orange) -- 462 Samples
         !!dict.make
         dict.add (174, climate_toxic)
         dict.add (314, climate_radiated)
         dict.add (766, climate_barren)
         dict.add (807, climate_desert)
         dict.add (894, climate_tundra)
         dict.add (922, climate_ocean)
         dict.add (942, climate_swamp)
         dict.add (960, climate_arid)
         dict.add (997, climate_terran)
         dict.add (1000, climate_gaia)
        Result.add (dict, kind_red) -- 967 Samples
         !!dict.make
         dict.add (208, climate_toxic)
         dict.add (500, climate_radiated)
         dict.add (600, climate_barren)
         dict.add (800, climate_desert)
         dict.add (900, climate_tundra)
         dict.add (920, climate_ocean)
         dict.add (940, climate_swamp)
         dict.add (960, climate_arid)
         dict.add (990, climate_terran)
         dict.add (1000, climate_gaia)
        Result.add (dict, kind_brown) -- 0 Samples
    end

    planet_sizes: DICTIONARY[INTEGER, INTEGER] is
      -- Accumulated probability for a planet being a certain size.
      -- Independent of star-kinds and galaxy ages
    once
        !!Result.make
        Result.add (100, plsize_tiny)
        Result.add (293, plsize_small)
        Result.add (704, plsize_medium)
        Result.add (904, plsize_large)
        Result.add (1000, plsize_huge)
    end


    planet_gravs: DICTIONARY[DICTIONARY[INTEGER, INTEGER], INTEGER] is
      -- Planet Gravity probabilities, indexed by star kind
    local
        dict: DICTIONARY[INTEGER, INTEGER]
    once
        !!Result.make
        !!dict.make
        dict.add (42, grav_lowg)
        dict.add (711, grav_normalg)
        dict.add (1000, grav_highg)
        Result.add (dict, kind_bluewhite)
        !!dict.make
        dict.add (106, grav_lowg)
        dict.add (807, grav_normalg)
        dict.add (1000, grav_highg)
        Result.add (dict, kind_white)
        !!dict.make
        dict.add (138, grav_lowg)
        dict.add (841, grav_normalg)
        dict.add (1000, grav_highg)
        Result.add (dict, kind_yellow)
        !!dict.make
        dict.add (221, grav_lowg)
        dict.add (933, grav_normalg)
        dict.add (1000, grav_highg)
        Result.add (dict, kind_orange)
        !!dict.make
        dict.add (296, grav_lowg)
        dict.add (958, grav_normalg)
        dict.add (1000, grav_highg)
        Result.add (dict, kind_red)
        !!dict.make
        dict.add (136, grav_lowg)
        dict.add (909, grav_normalg)
        dict.add (1000, grav_highg)
        Result.add (dict, kind_brown)
    end

    planet_minerals: DICTIONARY[DICTIONARY[INTEGER, INTEGER], INTEGER] is
      -- planet Mineral richness, indexed by star kind
    local
        dict: DICTIONARY[INTEGER, INTEGER]
    once
        !!Result.make
         !!dict.make
         dict.add (1, mnrl_ultrapoor)
         dict.add (2, mnrl_poor)
         dict.add (399, mnrl_abundant)
         dict.add (815, mnrl_rich)
         dict.add (1000, mnrl_ultrarich)
        Result.add (dict, kind_bluewhite)
         !!dict.make
         dict.add (1, mnrl_ultrapoor)
         dict.add (196, mnrl_poor)
         dict.add (608, mnrl_abundant)
         dict.add (902, mnrl_rich)
         dict.add (1000, mnrl_ultrarich)
        Result.add (dict, kind_white)
         !!dict.make
         dict.add (1, mnrl_ultrapoor)
         dict.add (304, mnrl_poor)
         dict.add (708, mnrl_abundant)
         dict.add (915, mnrl_rich)
         dict.add (1000, mnrl_ultrarich)
        Result.add (dict, kind_yellow)
         !!dict.make
         dict.add (104, mnrl_ultrapoor)
         dict.add (506, mnrl_poor)
         dict.add (896, mnrl_abundant)
         dict.add (999, mnrl_rich)
         dict.add (1000, mnrl_ultrarich)
        Result.add (dict, kind_orange)
         !!dict.make
         dict.add (186, mnrl_ultrapoor)
         dict.add (569, mnrl_poor)
         dict.add (992, mnrl_abundant)
         dict.add (996, mnrl_rich)
         dict.add (1000, mnrl_ultrarich)
        Result.add (dict, kind_red)
         !!dict.make
         dict.add (50, mnrl_ultrapoor)
         dict.add (160, mnrl_poor)
         dict.add (770, mnrl_abundant)
         dict.add (950, mnrl_rich)
         dict.add (1000, mnrl_ultrarich)
        Result.add (dict, kind_brown)
    end


    mindelta: REAL is 25
    maxdelta: REAL is 50

invariant
    size /= Void
    limit /= Void
    star_kinds /= Void
    planet_climates /= Void
    mindelta < maxdelta
end
