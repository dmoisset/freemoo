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
        ship: ITERATOR[SHIP]
        alienfleet, ownfleet: ITERATOR[FLEET]
        star: ITERATOR[STAR]
        planet: ITERATOR[PLANET]
        closest: INTEGER
        ships_detected: BOOLEAN
        fleet: FLEET
    do
        if player.sees_all_ships then
            !!Result.make(1, 0)
            from
                alienfleet := fleets.get_new_iterator_on_items
            until
                alienfleet.is_off
            loop
                if alienfleet.item.owner /= player then
                    Result.add_last(alienfleet.item)
                end
                alienfleet.next
            end
        else
            !!Result.with_capacity(0,1)
            from
                alienfleet := fleets.get_new_iterator_on_items
            until alienfleet.is_off loop
            -- Find own closest asset, in parsecs.
            -- (Can be at negative distances, due to modifiers)
            -- (Currently doesn't consider any modifiers!)
                from ownfleet:=fleets.get_new_iterator_on_items
                until ownfleet.is_off loop
                    closest := closest.min((ownfleet.item |-| alienfleet.item).rounded)
                    ownfleet.next
                end
                from star := stars.get_new_iterator_on_items
                until star.is_off loop
                    from planet := star.item.planets.get_new_iterator
                    until planet.is_off loop
                        if planet.item /= Void and then planet.item.colony /= Void and then planet.item.colony.owner = player then
                            closest := closest.min((planet.item.orbit_center |-| alienfleet.item).rounded)
                        end
                        planet.next
                    end
                    star.next
                end
            -- Determine which ships in alien fleet are detected, and report them
                from
                    ships_detected := False
                    ship:=alienfleet.item.get_new_iterator
                until ship.is_off loop
                    if (not ship.item.is_stealthy) and (ship.item.size >= closest) then
                        if not ships_detected then
                            ships_detected := True
                            !!fleet.make
                            fleet.set_owner(alienfleet.item.owner)
                            if alienfleet.item.is_stopped then
                                fleet.enter_orbit(alienfleet.item.orbit_center)
                            else
                                fleet.set_destination(alienfleet.item.destination)
                                fleet.set_eta(alienfleet.item.eta)
                            end
                        end
                        fleet.add_ship(ship.item)
                    end
                    ship.next
                end
                if ships_detected and fleet.owner /= player then
                    Result.add_last(fleet)
                end
                alienfleet.next
            end
        end
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