deferred class MAP_GENERATOR_V1

inherit
    MAP_GENERATOR
        redefine
            make;
    MAP_CONSTANTS
    MAP_PROBABILITIES
    PKG_USER

feature{NONE} -- Creation

    make (options: SERVER_OPTIONS) is
    require
        options /= Void
    local
    do
        size := options.enum_options_names @ "galaxysize"
        galage := options.enum_options_names @ "galaxyage"
        !!dont_touch.make

        if size.is_equal("small") then
            !!limit.make_at (20, 14.7)
            starcount := 20
        elseif size.is_equal("medium") then
            !!limit.make_at (27, 19)
            starcount := 36
        elseif size.is_equal("large") then
            !!limit.make_at (33, 23)
            starcount := 54
        elseif size.is_equal("huge") then
            !!limit.make_at (38, 27)
            starcount := 71
        end
        -- Load constants for given galaxy age
        load (galage)
    end

feature {NONE} -- Position Generation

    make_positions: ARRAY[COORDS] is
        -- Return an array og star positions
    deferred
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

        pkg_system.open_file ("galaxy/starnames.txt")
        file := pkg_system.last_file_open
            check starnames_file_exists: file /= Void end

        -- Load star names
        from until file.end_of_input loop
            file.read_line
            buffer.add_last (clone(file.last_string))
        end
        file.disconnect

        -- Set star names
            check enough_names: buffer.count >= starcount end
            check buffer.count = buffer.upper end -- Assumed below
        from until Result.count = starcount loop
            rand.next
            index := rand.last_integer (buffer.count)
            Result.add_last (buffer.item (index))
            -- Remove used starname
            buffer.swap (index, buffer.upper)
            buffer.remove_last
        end
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
            if rand.last_integer (100) <= planet_prob @ (star.kind) then
                !!planet.make (star, planet_sizes.random_item,
                planet_climates.item (star.kind).random_item,
                planet_minerals.item (star.kind).random_item,
                planet_gravs.item (star.kind).random_item,
                planet_types.random_item, plspecial_nospecial)
                star.set_planet (planet, i)
            end
            i := i + 1
        end
    end

    place_orion (starlist: DICTIONARY[STAR, INTEGER]) is
    local
        orion_system: STAR
        orion: PLANET
    do
        orion_system := closest_star_to_or_within (center, 8, starlist)
        !!orion.make (orion_system, plsize_huge, climate_gaia,
                      mnrl_ultrarich, grav_normalg, type_planet,
                      plspecial_nospecial)
        rand.next
        orion_system.set_planet (orion, rand.last_integer (5))
        orion_system.set_special (stspecial_orion)
        orion_system.set_name ("Orion")
        dont_touch.add (orion_system.id)
    end

    place_homeworlds(starlist: DICTIONARY[STAR, INTEGER]; players: PLAYER_LIST[PLAYER]) is
    local
        hmworldnams: ARRAY[STRING]
        i: ITERATOR_ON_COLLECTION[STRING]
        hmworldpos: COORDS
        step, offset: REAL
        done: INTEGER
        hmworld_system: STAR
        hmworld: PLANET
    do
        hmworldnams := <<"Color 1 Homeworld", "Color 2 Homeworld",
        "Color 3 Homeworld", "Color 4 Homeworld", "Color 5 Homeworld"
        "Color 6 Homeworld", "Color 7 Homeworld", "Color 8 Homeworld">>
        -- player colors star with 0
        hmworldnams.reindex (0)
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
            hmworld_system := closest_star_to (hmworldpos, starlist)
            !!hmworld.make (hmworld_system, plsize_medium,
                            climate_terran, mnrl_abundant, grav_normalg,
                            type_planet, plspecial_nospecial)
            rand.next
            hmworld_system.set_planet (hmworld, rand.last_integer (5))
            hmworld_system.set_name (hmworldnams.item ((players @ (i.item)).color_id))
            done := done + 1
            dont_touch.add (hmworld_system.id)
            i.next
        end
    end

feature{NONE} -- Internal

    closest_star_to (c: COORDS; starlist: DICTIONARY[STAR, INTEGER]): STAR is
    require
        c /= Void
    local
        curs: ITERATOR[STAR]
        dist: REAL
    do
        dist := Maximum_real
        from
            curs := starlist.get_new_iterator_on_items
        until
            curs.is_off
        loop
            if curs.item /= Void and then
            ((not dont_touch.has (curs.item.id)) and (curs.item |-| c) <= dist) then
                dist := curs.item |-| c
                Result := curs.item
            end
            curs.next
        end
    end

    closest_star_to_or_within (c: COORDS; threshold: INTEGER; starlist: DICTIONARY[STAR, INTEGER]): STAR is
    require
        c /= Void
    local
        curs: ITERATOR[STAR]
        dist: REAL
    do
        dist := Maximum_real
        from
            curs := starlist.get_new_iterator_on_items
        until
            curs.is_off or dist < threshold
        loop
            if curs.item /= Void and then
            ((not dont_touch.has (curs.item.id)) and (curs.item |-| c) <= dist) then
                dist := curs.item |-| c
                Result := curs.item
            end
            curs.next
        end
    end

feature -- Operation
    generate (galaxy: GALAXY; players: PLAYER_LIST [PLAYER]) is
    require
        fresh_galaxy: galaxy.stars.count = 0
    local
        starposs: ARRAY[COORDS]
        starnams: ARRAY[STRING]
        i: INTEGER
        newstar: STAR
        planets: ARRAY[PLANET]
    do
        galaxy.set_limit(limit)
        !!planets.make(1,0)
        print("Generating Positions%N")
        starposs := make_positions
        print("Generating Names%N")
        starnams := generate_names
        print("Generating Planets%N")
        from
            i := starposs.lower
        until
            i > starposs.upper
        loop
            rand.next
            newstar := galaxy.create_star
            newstar.move_to(starposs @ i)
            newstar.set_name(starnams @ i)
            newstar.set_kind(star_kinds.random_item)
            newstar.set_size(star_sizes.random_item)
            make_planets_on (newstar)
            galaxy.stars.add(newstar, newstar.id)
            i := i + 1
        end
        print ("Placing Orion%N")
        place_orion (galaxy.stars)

        print ("Placing HomeWorlds%N")
        !!homeworlds.make (1, players.count)
        place_homeworlds (galaxy.stars, players)
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

    mindelta: REAL is 2.5
    maxdelta: REAL is 5

invariant
    size /= Void
    limit /= Void
    star_kinds /= Void
    planet_climates /= Void
    mindelta < maxdelta

end -- deferred class MAP_GENERATOR_V1
