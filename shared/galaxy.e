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
    end

feature -- Access

    fleets: DICTIONARY [FLEET, INTEGER]
        -- All fleets in space

    limit: COORDS
        -- Outermost corner of galaxy, opposite to (0, 0)

    scanner (player: PLAYER):ARRAY[FLEET] is
        -- All fleets detected by `player' (not including their own)
    local
        alienship: ITERATOR[SHIP]
        alienfleet, ownfleet: ITERATOR[FLEET]
        owncolony: ITERATOR[COLONY]
        ships_detected, detected: BOOLEAN
        fleet: FLEET
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

    scans: DICTIONARY [ARRAY [FLEET], INTEGER]
        -- Fleets scanned by each player

    closest_star_to_or_within (c: COORDS; threshold: INTEGER; exclude: SET [STAR]): STAR is
        -- Star not in `exclude' within `threshold' of `c', or closest
        -- if not found.
    require
        c /= Void
    local
        curs: ITERATOR[STAR]
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

    closest_star_to (c: COORDS; exclude: SET [STAR]): STAR is
        -- Star closest to `c' not in `exclude'
    require
        c /= Void
    local
        curs: ITERATOR[STAR]
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

    last_star: STAR

feature -- Operations

    generate_scans (pl: PLAYER_LIST [PLAYER]) is
        -- Store in `scans' current scanner for all players in `pl'
    require
        pl /= Void
    local
        i: ITERATOR [PLAYER]
    do
        i := pl.get_new_iterator
        from
            i.start
            scans.clear
        until i.is_off loop
            scans.put (scanner (i.item), i.item.id)
            i.next
        end
    end

    add_fleet (new_fleet: FLEET) is
    require
        new_fleet /= Void
        not fleets.has(new_fleet.id)
        new_fleet.orbit_center /= Void implies new_fleet.orbit_center.fleets.has (new_fleet.id)
    do
        fleets.add(new_fleet, new_fleet.id)
    ensure
        fleets.has(new_fleet.id)
    end

    remove_fleet (f: FLEET) is
    require
        f /= Void
    do
        if f.is_in_orbit then f.leave_orbit end
        fleets.remove (f.id)
    end

    fleet_orders (fleet: FLEET; destination: STAR; ships: SET[SHIP]) is
        -- Set fleet orders of `fleet', sending its `ships' toward 
        -- `destination'
    require
        fleet /= Void and destination /= Void and ships /= Void
        stars.has (destination.id)
        fleets.has (fleet.id)
        not ships.is_empty
        -- ships.for_all (agent fleet.has_ship (?))
    local
        f: FLEET
    do
        f := fleet
        if ships.count /= f.ship_count then
            f.split (ships)
            f := f.splitted_fleet
            f.set_destination (destination)
            add_fleet (f)
        else
            f.set_destination (destination)
        end
        if f.orbit_center /= Void then
            join_fleets (f.orbit_center)
        end
    end

    join_fleets (s: STAR) is
        -- Join fleets at `s' sharing destination
    require
        stars.has (s.id)
    local
        fs: ARRAY [FLEET]
        sorter: COLLECTION_RELATION_SORTER [FLEET]
        i: INTEGER
        f, g: FLEET
    do
--        print ("Looking for fleets to join at "+s.name+"%N")
        -- Get and group fleets at s
        !!fs.with_capacity (s.fleets.count, 1)
        s.fleets.do_all (agent fs.add_last (?))
        sorter.set_order (agent fleet_ungrouping(?, ?))
        sorter.sort (fs)
--        print ("  Checking "+fs.count.to_string+" fleets %N")
        -- Join
        from i := fs.lower until i >= fs.upper loop -- >= instead of > because we compare each pair
            f := fs @ i
            g := fs @ (i+1)
            if not fleet_ungrouping (f, g) then
                    check f.owner = g.owner end
                    check f.destination = g.destination end
--                print ("  Must join fleets "+f.id.to_string+
--                       " and "+g.id.to_string+"%N")
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
        i: ITERATOR [FLEET]
        dead: SET [FLEET]
    do
        !!dead.make
        from i := fleets.get_new_iterator_on_items until i.is_off loop
            if i.item.ship_count = 0 then
                dead.add (i.item)
            end
            i.next
        end
        from i := dead.get_new_iterator until i.is_off loop
            fleets.remove (i.item.id)
            if i.item.is_in_orbit then
                i.item.leave_orbit -- To remove from star
            end
            i.next
        end
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

    create_fleet:FLEET is
    do
        !!Result.make
    end

feature {MAP_GENERATOR} -- Generation

    set_stars (starlist: DICTIONARY[STAR, INTEGER]) is
    require
        starlist /= Void
    do
        stars := starlist
    ensure
        stars = starlist
    end

    set_limit (l: COORDS) is
    require
        l /= Void
    do
        limit := l
    ensure
        limit = l
    end

feature {NONE} -- Representation

    stars: DICTIONARY [STAR, INTEGER]
        -- stars in the map, by id

invariant
    stars /= Void
    fleets /= Void

end -- class GALAXY
