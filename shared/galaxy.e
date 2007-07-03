class GALAXY

inherit
    STAR_MAP
        rename make as make_stars end
    FLEET_MAP
        rename make as make_fleets redefine star_type end

creation
    make

feature {NONE} -- Creation

    make is
    do
        make_stars
        make_fleets
        !!scans.make
        !!enemy_colony_knowledge.make
    end

feature -- Access

    scanner (player: PLAYER): ARRAY [like last_fleet] is
        -- All fleets detected by `player' (not including their own)
    local
        alienship: ITERATOR[like ship_type]
        alienfleet, ownfleet: ITERATOR [like last_fleet]
        owncolony: ITERATOR[COLONY]
        ships_detected, detected: BOOLEAN
        fleet: like last_fleet
    do
        !!Result.with_capacity(0,1)
        from
            alienfleet := fleets.get_new_iterator_on_items
        until alienfleet.is_off loop
            ships_detected := False
            if alienfleet.item.owner /= player then
                from alienship := alienfleet.item.get_new_iterator
                until alienship.is_off loop
                    detected := False
                    from ownfleet := fleets.get_new_iterator_on_items
                    until ownfleet.is_off or detected loop
                        if ownfleet.item.owner = player and then ownfleet.item.scan(alienfleet.item, alienship.item) then
                            detected := True
                            if not ships_detected then
                                ships_detected := True
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
                            detected := True
                            if not ships_detected then
                                ships_detected := True
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
    end

    calculate_enemy_colony_knowledge(player: PLAYER): HASHED_SET[COLONY] is
        -- All enemy colonies known by `player'
    local
        c: ITERATOR[COLONY]
        f: ITERATOR[like last_fleet]
        p: ITERATOR[PLANET]
        s: ITERATOR[like last_star]
    do
        create Result.make
        if player.race.omniscient then
            -- Omniscient races simply know everything
            from
                s := get_new_iterator_on_stars
            until
                s.is_off
            loop
                from
                    p := s.item.get_new_iterator_on_planets
                until
                    p.is_off
                loop
                    if p.item /= Void and then
                       p.item.colony /= Void and then
                       p.item.colony.owner /= player then
                        Result.add(p.item.colony)
                    end
                    p.next
                end
                s.next
            end
        else
            -- Regular races have their previous knowledge plus that of
            -- colonies over which they have fleets
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
    end

    scans: HASHED_DICTIONARY [ARRAY [like last_fleet], INTEGER]
        -- Fleets scanned by each player

    enemy_colony_knowledge: HASHED_DICTIONARY [HASHED_SET [COLONY], INTEGER]
        -- Enemy colonies known by each player.
        -- Eventually should be changed for something that contains
        -- all visible information, to show the colonies as each player 
        -- knew them.

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

feature -- Anchors

    planet_type: PLANET

    star_type: like last_star

end -- class GALAXY
