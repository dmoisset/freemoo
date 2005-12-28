class FLEET_MAP

create make

feature {NONE} -- Creation

    make is
    do
        create fleets.make
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

    local_fleet (location: STAR; owner: PLAYER): like last_fleet is
        -- Find fleet orbiting `location' from player, if available.
    local
        i: ITERATOR [like last_fleet]
    do
        from i := get_new_iterator_on_fleets until
            i.is_off or else
            (i.item.is_stopped and 
             i.item.orbit_center = location and
             i.item.owner = owner
            )
        loop i.next end
        if not i.is_off then Result := i.item end
    end

feature -- Operations

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
        fleets.remove (f.id)
    end

    fleet_orders (fleet: like last_fleet; destination: like star_type; ships: HASHED_SET[like ship_type]) is
        -- Set fleet orders of `fleet', sending its `ships' toward 
        -- `destination'
    require
        fleet /= Void and destination /= Void and ships /= Void
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

    join_fleets (s: like star_type) is
        -- Join fleets at `s' sharing destination
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
        dead: HASHED_SET [like last_fleet]
    do
        create dead.make
        from i := fleets.get_new_iterator_on_items until i.is_off loop
            if i.item.ship_count = 0 then
                dead.add(i.item)
            end
            i.next
        end
        dead.do_all(agent remove_fleet)
    end

    last_fleet: FLEET

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

    create_fleet: like last_fleet is
    do
        !!Result.make
        last_fleet := Result
    end

feature {NONE} -- Representation

    fleets: HASHED_DICTIONARY [like last_fleet, INTEGER]
        -- All fleets in space
    
feature {NONE} -- Anchors

    ship_type: SHIP

    star_type: STAR

invariant
    fleets /= Void

end