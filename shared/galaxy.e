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

    stars: DICTIONARY [STAR, INTEGER]
        -- stars in the map, by id

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
		print("Scanner for player " + player.id.to_string)
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
		print(" picks up " + Result.count.to_string + " alien fleets%N")
    end

    scans: DICTIONARY [ARRAY [FLEET], INTEGER]
        -- Fleets scanned by each player

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
    do
        fleets.add(new_fleet, new_fleet.id)
        if new_fleet.orbit_center /= Void then
            new_fleet.orbit_center.fleets.add(new_fleet, new_fleet.id)
        end
    ensure
        fleets.has(new_fleet.id)
    end

    fleet_orders (fleet: FLEET; destination: STAR; ships: SET[SHIP]) is
        -- Set fleet orders of `fleet', sending its `ships' toward 
        -- `destination'
    require
        fleet /= Void and destination /= Void and ships /= Void
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
    end

feature -- Factory methods

    create_star:STAR is
    do
        !!Result.make_defaults
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

invariant
    stars /= Void
    fleets /= Void

end -- class GALAXY
