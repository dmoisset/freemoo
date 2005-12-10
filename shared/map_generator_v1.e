deferred class MAP_GENERATOR_V1

inherit
    MAP_GENERATOR
    redefine make end
    MAP_CONSTANTS
    MAP_PROBABILITIES
    PKG_USER

feature{NONE} -- Creation

    make (options: SERVER_OPTIONS) is
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

    fill_carefully (res: ARRAY [COORDS]) is
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
                goodstar (newc, res.get_new_iterator)
            loop
                newc := newcoords
            end
            res.add_last(newc)
        end
    ensure
        res.count = starcount
    end

    bunched_up (this: COORDS; here: ITERATOR [COORDS]): BOOLEAN is
        -- true if closer than mindelta to another star
    do
        from until here.is_off or Result
        loop
            Result := here.item /= this and then ((here.item |-| this) < mindelta)
            here.next
        end
    end

    too_far_away (this: COORDS; here: ITERATOR [COORDS]): BOOLEAN is
        -- true if this' nearest neighbour is farther than maxdelta away
    local
        farthest: REAL
    do
        from
            farthest := maxdelta + 1
            Result := not here.is_off -- not empty list
        until
            here.is_off
        loop
            if this /= here.item then
                farthest := farthest.min(this |-| here.item)
            end
            here.next
        end
        Result := (farthest > maxdelta) and Result
    end

    goodstar (this: COORDS; here: ITERATOR [COORDS]): BOOLEAN is
        -- Optimization for not_bunched and too_far_away, goes over
        -- the structure only once
    local
        farthest: REAL
        empty: BOOLEAN
    do
        Result := true
        farthest := maxdelta + 1
        empty := here.is_off
        from until here.is_off or not Result
        loop
            if (this |-| here.item) < mindelta then
                Result := false
            end
            farthest := farthest.min (this |-| here.item)
            here.next
        end
        if farthest > maxdelta and not empty then
            Result := false
        end
    ensure
-- Invalidated because here is modified
--        Result = not (bunched_up (this, here) or too_far_away (this, here))
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
            if not file.last_string.is_equal("") then
                buffer.add_last (clone(file.last_string))
            end
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

    create_random_planet(star: STAR): PLANET is
    -- Create a random planet for `star'
    do
        Result := star.create_planet
        Result.set_size(planet_sizes.random_item)
        Result.set_climate(planet_climates.item(star.kind).random_item)
        Result.set_mineral(planet_minerals.item(star.kind).random_item)
        Result.set_gravity(planet_gravs.item(star.kind).random_item)
        Result.set_type(type_planet)
        Result.set_special(plspecial_nospecial)
    end

    create_default_homeworld(star: STAR): PLANET  is
    -- Create a medium, terran, NG, abundand planet for `star'
    do
        Result := star.create_planet
        Result.set_size(plsize_medium)
        Result.set_climate(climate_terran)
        Result.set_mineral(mnrl_abundant)
        Result.set_gravity(grav_normalg)
        Result.set_type(type_planet)
        Result.set_special(plspecial_nospecial)
    end

    make_special_on (star: STAR; galaxy: GALAXY) is
    local
        special, orbit, idx: INTEGER
        other: STAR
        star_it: ITERATOR[STAR]
    do
        if star.kind /= kind_blackhole and not dont_touch.has(star) then
            special := star_specials.random_item
            if special = stspecial_wormhole then
            -- Can't add a wormhole if there are no stars left.
            -- If we're trying to add a wormhole to the last star, just
            -- leave it as stspecial_nospecial
                from
                    star_it := galaxy.get_new_iterator_on_stars
                until
                    star_it.is_off or else
                    (star_it.item.kind /= kind_blackhole and
                    not dont_touch.has(star) and
                    star_it.item /= star)
                loop
                    star_it.next
                end
                if star_it.is_off then
                    special := stspecial_nospecial
                end
            end
            star.set_special(special)
            if special /= stspecial_nospecial then
                dont_touch.add(star)
            end
            if special = stspecial_wormhole then
            -- Setup Wormholes
                from
                    star.set_special(stspecial_nospecial)
                until
                    star.special = stspecial_wormhole
                loop
                    rand.next
                    idx := rand.last_integer(galaxy.stars.count) - 1 + galaxy.stars.lower
                    other := galaxy.stars.item(idx)
                    if other.kind /= kind_blackhole and not dont_touch.has(other) then
                        star.setup_wormhole_to(other)
                        dont_touch.add(other)
                    end
                end
            elseif special = stspecial_planetspecial then
            -- Setup Planet specials
                rand.next
                special := rand.last_integer(plspecial_max - plspecial_min - 1) + plspecial_min
                check special.in_range(plspecial_min + 1, plspecial_max) end
                rand.next
                orbit := rand.last_integer(star.Max_planets)
                if special = plspecial_splinter or special = plspecial_natives then
                    star.set_planet(create_default_homeworld(star), orbit)
                else
                    star.set_planet(create_random_planet(star), orbit)
                end
                star.planet_at(orbit).set_special(special)
            -- Setup other specials
            end
        end
    end

    make_planets_on (star: STAR) is
    local
        i: INTEGER
        planet: PLANET
        type: INTEGER
    do
        from
            i := 1
        until
            i > star.Max_planets
        loop
            rand.next
            if rand.last_integer (100) <= planet_prob @ (star.kind) then
                type := planet_types.random_item
                if type = type_planet then
                    planet := create_random_planet(star)
                else
                    planet := star.create_planet
                    planet.set_type(type)
                end
                star.set_planet (planet, i)
            end
            i := i + 1
        end
    end

    place_orion (galaxy: GALAXY) is
    local
        orion_system: STAR
        orion: PLANET
    do
        orion_system := galaxy.closest_star_to_or_within (center, 8, dont_touch)
        orion := orion_system.create_planet
        orion.set_size(plsize_huge)
        orion.set_climate(climate_gaia)
        orion.set_mineral(mnrl_ultrarich)
        orion.set_gravity(grav_normalg)
        orion.set_type(type_planet)
        orion.set_special(plspecial_nospecial)
        rand.next

        orion_system.set_planet (orion, rand.last_integer (orion_system.Max_planets))
        orion_system.set_special (stspecial_orion)
        from
        until
            orion_system.kind /= kind_blackhole
        loop
            orion_system.set_kind(star_kinds.random_item)
        end
        orion_system.set_name ("Orion")
        dont_touch.add (orion_system)
    end

    place_homeworlds(galaxy: GALAXY; players: PLAYER_LIST[PLAYER]) is
    local
        i: ITERATOR [PLAYER]
        hmworldpos: COORDS
        step, offset: REAL
        done: INTEGER
        hmworld_system: STAR
        hmworld: PLANET
        newcol: COLONY
    do
        step := perimeter / players.count
        rand.next
        offset := rand.last_real * step
        i := players.get_new_iterator
        from
            done := 0
            i.start
        until i.is_off loop
            hmworldpos := walk_point (step * done + offset)
            hmworld_system := galaxy.closest_star_to (hmworldpos, dont_touch)
            hmworld := create_default_homeworld(hmworld_system)
            hmworld.set_size(plsize_medium + i.item.race.homeworld_size)
            if i.item.race.aquatic then
                hmworld.set_climate(climate_ocean)
            end
            hmworld.set_mineral(mnrl_abundant + i.item.race.homeworld_richness)
            hmworld.set_gravity(grav_normalg + i.item.race.homeworld_gravity)
            if i.item.race.ancient_artifacts then
                hmworld.set_special(plspecial_artifacts)
            end
            rand.next
            hmworld_system.set_planet (hmworld, rand.last_integer (hmworld_system.Max_planets))
            hmworld_system.set_name (i.item.race.homeworld_name)
            from
            until hmworld_system.kind /= kind_blackhole
            loop hmworld_system.set_kind(star_kinds.random_item)
            end
            newcol := hmworld.create_colony(i.item)
            i.item.add_to_known_list (hmworld_system)
            i.item.add_to_visited_list (hmworld_system)
            done := done + 1
            dont_touch.add (hmworld_system)
            i.next
        end
    end

feature -- Operation

    generate (galaxy: GALAXY; players: PLAYER_LIST [PLAYER]) is
    local
        starposs: ARRAY[COORDS]
        starnams: ARRAY[STRING]
        i: INTEGER
        planets: ARRAY[PLANET]
        star_it: ITERATOR[STAR]
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
            galaxy.create_star
            galaxy.last_star.move_to(starposs @ i)
            galaxy.last_star.set_name(starnams @ i)
            galaxy.last_star.set_kind(star_kinds.random_item)
            galaxy.last_star.set_size(star_sizes.random_item)
            make_planets_on (galaxy.last_star)
            i := i + 1
        end
        print ("Placing Orion%N")
        place_orion (galaxy)
        print ("Placing HomeWorlds%N")
        !!homeworlds.make (1, players.count)
        place_homeworlds (galaxy, players)
        print ("Placing specials%N")
        from
            star_it := galaxy.stars.get_new_iterator_on_items
        until
            star_it.is_off
        loop
            make_special_on(star_it.item, galaxy)
            star_it.next
        end
        add_omniscient_knowledge(galaxy, players)
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
        !!Result.with_seed (epoch.elapsed_seconds (today).rounded)
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

    dont_touch: HASHED_SET [STAR]
        -- Stars that souldn't be modified any more, thank you.

feature{NONE} -- Internal Constants

    mindelta: REAL is 3
    maxdelta: REAL is 4

invariant
    size /= Void
    limit /= Void
    star_kinds /= Void
    planet_climates /= Void
    mindelta < maxdelta

end -- deferred class MAP_GENERATOR_V1
