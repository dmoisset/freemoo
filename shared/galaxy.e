class GALAXY

creation make

feature {NONE} -- Creation

    make is
    do
        !!limit.make_at(0, 0)
        !!stars.with_capacity (0, 1)
        !!fleets.with_capacity (0,1)
    end

feature -- Access

    stars: ARRAY [STAR]
        -- stars in the map, by id

    fleets: ARRAY [FLEET]
        -- All fleets in space

    limit: COORDS
        -- Outermost corner of galaxy, opposite to (0, 0)

    scanner (player: PLAYER):ARRAY[FLEET] is
        -- All fleets detected by `player'
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
            Result := fleets
        else
            !!Result.with_capacity(0,1)
            from
                alienfleet := fleets.get_new_iterator
            until alienfleet.is_off loop
                if alienfleet.item.owner /= player then
            -- Find own closest asset, in parsecs.
            -- (Can be at negative distances, due to modifiers)
            -- (Currently doesn't consider any modifiers!)
                    from ownfleet:=fleets.get_new_iterator
                    until ownfleet.is_off loop
                        closest := closest.min((ownfleet.item |-| alienfleet.item).rounded)
                        ownfleet.next
                    end
                    from star := stars.get_new_iterator
                    until star.is_off loop
                        from planet := star.item.planets.get_new_iterator
                        until planet.is_off loop
                            if planet.item.colony /= Void and then planet.item.colony.owner = player then
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
                            end
                            fleet.add_ship(ship.item)
                        end
                        ship.next
                    end
                    if ships_detected then
                        Result.add_last(fleet)
                    end
                end
                alienfleet.next
            end
        end
    end

feature -- Factory method for stars
    create_star:STAR is
    do
        !!Result.make_defaults
    end

feature {MAP_GENERATOR} -- Generation
    set_stars (starlist: ARRAY[STAR]) is
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