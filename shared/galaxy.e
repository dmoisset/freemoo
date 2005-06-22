class GALAXY

creation
    make

feature {NONE} -- Creation

    make is
    do
        !!limit.make_at(0, 0)
        !!stars.make
        !!fleets.make
        !!scans.make
        !!enemy_colony_knowledge.make
    end

feature -- Access

    limit: COORDS
        -- Outermost corner of galaxy, opposite to (0, 0)

    scanner (player: PLAYER): ARRAY [like last_fleet] is
        -- All fleets detected by `player' (not including their own)
    local
        alienship: ITERATOR[like ship_type]
        alienfleet, ownfleet: ITERATOR [like last_fleet]
        owncolony: ITERATOR[COLONY]
        ships_detected, detected: BOOLEAN
        fleet: like last_fleet
    do
        --		print("Scanner for player " + player.id.to_string)
        !!Result.with_capacity(0,1)
        from
            alienfleet := fleets.get_new_iterator_on_items
        until alienfleet.is_off loop
            ships_detected := false
            if alienfleet.item.owner /= player then
                from alienship := alienfleet.item.get_new_iterator
                until alienship.is_off loop
                    detected := false
                    from ownfleet := fleets.get_new_iterator_on_items
                    until ownfleet.is_off or detected loop
                        if ownfleet.item.owner = player and then ownfleet.item.scan(alienfleet.item, alienship.item) then
                            detected := true
                            if not ships_detected then
                                ships_detected := true
                                !!fleet.make
                                fleet.copy_from(alienfleet.item)
                            end
                            fleet.add_ship(alienship.item)
                        end
                        ownfleet.next
                    end
                    from owncolony := player.colonies.get_new_iterator_on_items
                    until owncolony.is_off or detected loop
                        if owncolony.item.scan(alienfleet.item, alienship.item) then
                            detected := true
                            if not ships_detected then
                                ships_detected := true
                                !!fleet.make
                                fleet.copy_from(alienfleet.item)
                            end
                            fleet.add_ship(alienship.item)
                        end
                        owncolony.next
                    end
                    alienship.next
                end
                if ships_detected then
                    Result.add_last(fleet)
                end
            end
            alienfleet.next
        end
        --		print(" picks up " + Result.count.to_string + " alien fleets%N")
    end
    
    calculate_enemy_colony_knowledge(player: PLAYER): SET[COLONY] is
        -- All enemy colonies known by `player'
    local
        c: ITERATOR[COLONY]
        f: ITERATOR[FLEET]
        p: ITERATOR[PLANET]
    do
        create Result.make
        if enemy_colony_knowledge.has(player.id) then
            from 
                c := (enemy_colony_knowledge @ (player.id)).get_new_iterator
            until c.is_off loop
                if c.item.location.colony /= Void then
                    Result.add(c.item)
                end
                c.next
            end
        end
        from
            f := fleets.get_new_iterator_on_items
        until f.is_off loop
            if f.item.orbit_center /= Void and f.item.owner = player then
                from
                    p := f.item.orbit_center.get_new_iterator_on_planets
                until p.is_off loop
                    if p.item /= Void and then p.item.colony /= Void and then p.item.colony.owner /= player then
                        Result.add(p.item.colony)
                    end
                    p.next
                end
            end
            f.next
        end
    end

    scans: DICTIONARY [ARRAY [like last_fleet], INTEGER]
        -- Fleets scanned by each player
    
    enemy_colony_knowledge: DICTIONARY [SET [COLONY], INTEGER]
        -- Enemy colonies known by each player.
        -- Eventually should be changed for something that contains
        -- all visible information, to show the colonies as each player 
        -- knew them.

feature -- Access -- star list

    closest_star_to_or_within (c: COORDS; threshold: INTEGER;
                               exclude: SET [STAR]): like last_star is
        -- Star not in `exclude' within `threshold' of `c', or closest
        -- if not found.
    require
        c /= Void
    local
        curs: ITERATOR[like last_star]
        dist: REAL
    do
        dist := Maximum_real
        from
            curs := stars.get_new_iterator_on_items
        until
            curs.is_off or dist < threshold
        loop
            if not exclude.has (curs.item) and (curs.item |-| c) <= dist then
                dist := curs.item |-| c
                Result := curs.item
            end
            curs.next
        end
    ensure
        not exclude.has (Result)
        -- Result |-| c < threshold or else Result is closest to c
    end

--reimplement with closest_star_or_within (...,0,...)
    closest_star_to (c: COORDS; exclude: SET [STAR]): like last_star is
        -- Star closest to `c' not in `exclude'
    require
        c /= Void
    local
        curs: ITERATOR[like last_star]
        dist: REAL
    do
        dist := Maximum_real
        from
            curs := stars.get_new_iterator_on_items
        until
            curs.is_off
        loop
            if not exclude.has (curs.item) and (curs.item |-| c) <= dist then
                dist := curs.item |-| c
                Result := curs.item
            end
            curs.next
        end
    ensure
        -- Result is closest to c
    end

    get_new_iterator_on_stars: ITERATOR [like last_star] is
    do
        Result := stars.get_new_iterator_on_items
    end
    
    has_star (sid: INTEGER): BOOLEAN is
        -- Is there a star with id `sid'?
    do
        Result := stars.has (sid)
    end
    
    star_with_id (sid: INTEGER): like last_star is
        -- Star with id `sid'
    require
        has_star (sid)
    do
        Result := stars @ sid
    end

    last_star: STAR

    exists_black_hole_between(s1, s2: POSITIONAL): BOOLEAN is
    require
        s1 /= Void
        s2 /= Void
    local
        sit: ITERATOR[STAR]
        trip: REAL
    do
        from
            sit := get_new_iterator_on_stars
        until sit.is_off or Result loop
            if sit.item.kind = sit.item.kind_blackhole and then
               sit.item.distance_to_segment(s1, s2) < 1.0 then
                trip := s1 |-| s2
                Result := sit.item.distance_to(s1) < trip and then
                          sit.item.distance_to(s2) < trip
            end
            sit.next
        end
    end
feature -- Access -- fleet list

    get_new_iterator_on_fleets: ITERATOR [like last_fleet] is
    do
        Result := fleets.get_new_iterator_on_items
    end

    has_fleet (fid: INTEGER): BOOLEAN is
        -- Is there a fleet with id `fid'?
    do
        Result := fleets.has (fid)
    end

    fleet_with_id (fid: INTEGER): like last_fleet is
        -- Fleet with id `fid'
    require
        has_fleet (fid)
    do
        Result := fleets @ fid
    end

    last_fleet: FLEET

feature -- Operations

    generate_scans (pl: ITERATOR [PLAYER]) is
        -- Store in `scans' current scanner for all players in `pl'
    require
        pl /= Void
    do
        from
            scans.clear
        until pl.is_off loop
            scans.put (scanner (pl.item), pl.item.id)
            pl.next
        end
    end
    
    generate_colony_knowledge (pl: ITERATOR [PLAYER]) is
        -- Store in `enemy_colony_knowledge' current knowledge of 
        -- enemy colonies for all players in `pl'
    require
        pl /= Void
    do
        from
        until pl.is_off loop
            enemy_colony_knowledge.put(calculate_enemy_colony_knowledge(pl.item), pl.item.id)
            pl.next
        end
    end
    
    add_fleet (new_fleet: like last_fleet) is
    require
        new_fleet /= Void
        not has_fleet (new_fleet.id)
    do
        fleets.add(new_fleet, new_fleet.id)
    ensure
        fleets.has(new_fleet.id)
    end

    remove_fleet (f: like last_fleet) is
    require
        f /= Void
    do
        if f.is_in_orbit then f.leave_orbit end
        fleets.remove (f.id)
    end

    fleet_orders (fleet: like last_fleet; destination: like last_star; ships: SET[like ship_type]) is
        -- Set fleet orders of `fleet', sending its `ships' toward 
        -- `destination'
    require
        fleet /= Void and destination /= Void and ships /= Void
        has_star (destination.id)
        has_fleet (fleet.id)
        not ships.is_empty
        -- ships.for_all (agent fleet.has_ship (?))
    local
        f: like last_fleet
    do
        f := fleet
        if ships.count /= f.ship_count then
            f.split (ships.get_new_iterator)
            f := f.splitted_fleet
            f.set_destination (destination)
            add_fleet (f)
        else
            f.set_destination (destination)
            if f.destination /= Void then
                f.recalculate_eta
            end
        end
        if f.orbit_center /= Void then
            join_fleets (f.orbit_center)
            fleet_cleanup
        end
    end

    join_fleets (s: like last_star) is
        -- Join fleets at `s' sharing destination
    require
        has_star (s.id)
    local
        fs: ARRAY [like last_fleet]
        fleet: ITERATOR[like last_fleet]
        sorter: COLLECTION_RELATION_SORTER [like last_fleet]
        i: INTEGER
        f, g: FLEET
    do
        -- Get and group fleets at s
        !!fs.make (1, 0)
        from
            fleet := get_new_iterator_on_fleets
        until
            fleet.is_off
        loop
            if fleet.item.orbit_center = s then
                fs.add_last(fleet.item)
            end
            fleet.next
        end
        sorter.set_order (agent fleet_ungrouping(?, ?))
        sorter.sort (fs)
        -- Join
        from i := fs.lower until i >= fs.upper loop -- >= instead of > because we compare each pair
            f := fs @ i
            g := fs @ (i+1)
            if not fleet_ungrouping (f, g) then
                    check f.owner = g.owner end
                    check f.destination = g.destination end
                f.join (g)
                fs.remove (i+1)
            else
                i := i + 1
            end
        end
    end

    fleet_cleanup is
        -- Remove all 0-sized (i.e. dead) fleets
    local
        i: ITERATOR [like last_fleet]
        dead: SET [like last_fleet]
    do
        !!dead.make
        from i := fleets.get_new_iterator_on_items until i.is_off loop
            if i.item.ship_count = 0 then
                dead.add(i.item)
            end
            i.next
        end
        dead.do_all(agent remove_fleet)
    end

feature {NONE} -- Auxiliar

    fleet_ungrouping (f, g: FLEET): BOOLEAN is
    do
        if f.owner.id < g.owner.id then
            Result := true
        elseif f.owner.id = g.owner.id then
            if f.destination = Void then
                Result := g.destination /= Void
            elseif g.destination = Void then
                Result := False
            else
                Result := f.destination.id < g.destination.id
            end
        end
    end

feature -- Factory methods

    create_star is
        -- Build a star with proper dynamic type, add it to galaxy and
        -- Store it into last_star.
    do
        !!last_star.make_defaults
        stars.add (last_star, last_star.id)
    end

    create_fleet: like last_fleet is
    do
        !!Result.make
        last_fleet := Result
    end

feature {MAP_GENERATOR} -- Generation

    set_limit (l: COORDS) is
    require
        l /= Void
    do
        limit := l
    ensure
        limit = l
    end

feature {NONE} -- Representation

    stars: DICTIONARY [like last_star, INTEGER]
        -- stars in the map, by id

    fleets: DICTIONARY [like last_fleet, INTEGER]
        -- All fleets in space
    
feature -- Anchors
    
    ship_type: SHIP
    
invariant
    stars /= Void
    fleets /= Void

end -- class GALAXY
