class MAP_GENERATOR_V1

inherit
    MAP_GENERATOR
        redefine
            make;
    MAP_CONSTANTS
    MAP_PROBABILITIES

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
            Result := here.item(j) /= this and then ((here.item(j) |-| this) < mindelta)
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

    place_homeworlds(starlist: ARRAY[STAR]; players: PLAYER_LIST[PLAYER]) is
    local
        hmworldnams: ARRAY[STRING]
        i: ITERATOR_ON_COLLECTION[STRING]
        hmworldpos: COORDS
        step, offset: REAL
        done: INTEGER
        hmworldind: INTEGER
        hmworld: PLANET
    do
        hmworldnams := <<"Color 0 Homeworld", "Color 1 Homeworld",
        "Color 2 Homeworld", "Color 3 Homeworld", "Color 4 Homeworld"
        "Color 5 Homeworld", "Color 6 Homeworld", "Color 7 Homeworld">>
-- Get this out.  Should be race homeworld names
        step := perimeter / players.count
        rand.next
        offset := rand.last_real * step
        from
            done := 0
            !!i.make (players.names)
        until
            i.is_off
        loop
            hmworldpos := walk_point (step * done + offset)
            hmworldind := closest_star_to (hmworldpos, starlist)
            !!hmworld.make (starlist.item (hmworldind), plsize_medium,
                            climate_terran, mnrl_abundant, grav_normalg,
                            type_planet, plspecial_nospecial)
            rand.next
            starlist.item (hmworldind).set_planet (hmworld, rand.last_integer (5))
            starlist.item (hmworldind).set_name (hmworldnams.item ((players @ (i.item)).color_id))
            dont_touch.add (hmworldind)
        end
    end

feature{NONE} -- Internal

    one_of (probs: ARRAY [TUPLE [INTEGER, INTEGER]]):INTEGER is
     -- Choose a random entry of probs.
     -- Tuples are (probability, value) probability of choosing value or less
     -- (in thousandths)
     -- If probs contains probabilities > 1000 or repeated values,
     --  it's your guess.
    require
        probs /= Void
    local
        curs: ITERATOR_ON_COLLECTION [TUPLE [INTEGER, INTEGER]]
        best: INTEGER
        choice: INTEGER
    do
        rand.next
        choice := rand.last_integer (1000)
        !!curs.make (probs)
        from
            curs.start
            best := 1001
        until
            curs.is_off or else (curs.item = Void)
        loop
            if curs.item.first.in_range (choice, best) then
                best := curs.item.first
                Result := curs.item.second
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
            if starlist.item (curs) /= Void and then
            ((not dont_touch.has (curs)) and (starlist.item (curs) |-| c) <= dist) then
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
            if starlist.item (curs) /= Void and then
            ((not dont_touch.has (curs)) and (starlist.item (curs) |-| c) <= dist) then
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
        print ("Placing Orion%N")
        place_orion (starlist)

        print ("Placing HomeWorlds%N")
        !!homeworlds.make (1, players.count)
        place_homeworlds (starlist, players)

        galaxy.set_stars (starlist)
    end


feature{NONE} -- Creation
    make (options: OPTION_LIST) is
    require
        options /= Void
    local
    do
        size := options.enum_options_names @ "galaxysize"
        galage := options.enum_options_names @ "galaxyage"
        !!dont_touch.make

        if size.is_equal("small") then
            !!limit.make_at (200, 147)
            starcount := 20
        elseif size.is_equal("medium") then
            !!limit.make_at (270, 190)
            starcount := 36
        elseif size.is_equal("large") then
            !!limit.make_at (330, 230)
            starcount := 54
        elseif size.is_equal("huge") then
            !!limit.make_at (380, 270)
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
    end

feature {NONE} -- Implementation

    rand: STD_RAND is
        -- Random number generator, used all over
    local
        today, epoch: TIME
        valid: BOOLEAN
    once
        today.update
        valid := epoch.set (1970, 1, 1, 0, 0, 0)
            check valid end -- Because 1/1/1970 IS a valid date
        !!Result.with_seed (epoch.elapsed_seconds (today))
    end

    size: STRING
        -- "small", "medium", "large" or "huge"

    galage: STRING
        -- "average", "organicrich" or "mineralrich"

    starcount: INTEGER
        -- Number of stars in galaxy, depends of size

    star_kinds: ARRAY [TUPLE [INTEGER, INTEGER]]
        -- Accumulative probability of a star being certain kind.
        -- One of average_star_kinds, orgrich_star_kinds or minrich_star_kinds

    planet_climates: DICTIONARY [ARRAY [TUPLE [INTEGER, INTEGER]], INTEGER]
        -- Probability for a star having a certain climate, indexed by
        -- star kind.  One of average_climates, orgrich_climates or
        -- minrich_climates

    limit: COORDS
        -- The outermost posible point in galaxy

    center: COORDS is
        -- Center of the galaxy
    once
        !!Result.make_at (limit.x / 2, limit.y / 2)
    end

    perimeter: REAL is
        -- galaxy's perimeter
    do
        Result := limit.x * 2 + limit.y * 2
    end

    walk_point (r: REAL): COORDS is
        -- Coords at distance r from origin of galaxy, walking along the
        -- perimeter
    require
        r.in_range (0, perimeter)
    do
        if r > limit.y + limit.x then
            if r > limit.x + 2 * limit.y then
                !!Result.make_at (perimeter - r, 0)
            else
                !!Result.make_at (limit.x, 2 * limit.y - r + limit.x)
            end
        else
            if r > limit.y then
                !!Result.make_at (r - limit.y, limit.x)
            else
                !!Result.make_at (0, r)
            end
        end
    end
    dont_touch: SET[INTEGER]
        -- Stars that souldn't be modified any more, thank you.


feature{NONE} -- Internal Constants

    mindelta: REAL is 25
    maxdelta: REAL is 50

invariant
    size /= Void
    limit /= Void
    star_kinds /= Void
    planet_climates /= Void
    mindelta < maxdelta
end
