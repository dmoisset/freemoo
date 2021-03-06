class FLEET
-- Group of SHIPs moving together

inherit
    UNIQUE_ID
    POSITIONAL
    ORBITING

creation
    make

feature -- Access

    owner: PLAYER
        -- Player that controls Current

    is_in_orbit: BOOLEAN is
        -- Is in orbit around a star?
    do
        Result := orbit_center /= Void
    ensure
        Result = (orbit_center /= Void)
    end

    destination: like orbit_center
        -- Star where to which the fleet is traveling, or Void if none

    current_speed: REAL
        -- Represents distance traveled by Current in one turn.
        -- Current_speed should be recalculated each time ships join 
        -- or leave the fleet, calling recalculate_current_speed.  
        -- It represents the fleet's base traveling speed, and is the 
        -- minimum of the fleet's ships' traveling speeds, plus modifiers

    eta: INTEGER
        -- Estimated time of arrival when traveling, 0 when not
        -- Should be recalculated each time the fleet receives new 
        -- orders calling recalculate_eta, and each time a turn 
        -- passes (substracting one)

    is_stopped: BOOLEAN is
        -- is stopped?
    do
        Result := destination = Void
    ensure
        Result = (destination = Void)
    end

    ship_count: INTEGER is
        -- Number of ships in fleet
    do
        Result := ships.count
    end

    has_ship (sid: INTEGER): BOOLEAN is
        -- fleet has a ship with id `sid'?
    do
        Result := ships.has (sid)
    end

    ship (sid: INTEGER): like ship_type is
        -- Ship in this fleet with id `sid'
    require
        has_ship (sid)
    do
        Result := ships @ sid
    end

    get_new_iterator: ITERATOR[like ship_type] is
        -- Returns an iterator on the fleet's ships
    do
        Result:= ships.get_new_iterator_on_items
    end

    splitted_fleet: like Current


    eta_at(dest: POSITIONAL):INTEGER is
        -- Estimate a time of arrival at `dest'
    require
        dest /= Void
        current_speed > 0
    do
        -- Consider wormholes
        if orbit_center /= Void and then orbit_center.wormhole = dest then
            Result := 1
        -- Consider other things
        else
            Result := ((Current |-| dest) / current_speed).ceiling
        end
    end

    can_receive_orders: BOOLEAN is
        -- Can this fleet receive new orders at the moment?
        -- In the future it should check owner's modifiers, advances 
        -- at destination, and other stuff.
    do
        Result := is_in_orbit
    end

    get_colony_ship: COLONY_SHIP is
    require
        can_colonize
    local
        it: ITERATOR[like ship_type]
    do
        from
            it := ships.get_new_iterator_on_items
        until
            it.item.can_colonize
        loop it.next end
        Result := it.item.as_colony_ship
    end

    has_target_at (g: GALAXY): BOOLEAN is
        -- Is there any attackable target in galaxy `g'?
    require
        g /= Void
        is_in_orbit implies g.has_star (orbit_center.id)
    local
        i: INTEGER
        p: PLANET
        f: ITERATOR [FLEET]
    do
        if is_in_orbit and then can_engage then
            -- Look for ground targets
            from i := 1 until i > orbit_center.Max_planets or Result loop
                p := orbit_center.planet_at (i)
                Result :=
                    p /= Void and then
                    p.colony /= Void and then
                    p.colony.owner /= owner
                i := i + 1
            end
            -- Look for enemy fleets
            from
                f := g.get_new_iterator_on_fleets
            until Result or f.is_off loop
                Result :=
                    f.item.orbit_center = orbit_center and then
                    f.item.owner /= owner
                f.next
            end
        end
    end

feature -- Operations

    add_ship (s: like ship_type) is
        -- Add `s' to fleet
    require
        s /= Void
        owner /= Void implies s.owner = owner
    do
        ships.put (s, s.id)
        scanner_range := 0
        recalculate_current_speed
    ensure
        has_ship (s.id)
    end

    remove_ship (s: like ship_type) is
        -- Remove `s' from fleet
    do
        ships.remove(s.id)
        if not can_colonize then
            has_colonization_orders := False
        end
        if not can_engage then
            has_engage_orders := False
        end
        scanner_range := 0
        recalculate_current_speed
    ensure
        not has_ship(s.id)
    end

    clear_ships is
    do
        ships.clear
        scanner_range := 0
    end

    join (other: like Current) is
        -- Join up with another fleet
    require
        other /= Void
    do
        other.ships.do_all (agent ships.put (?, ?))
        if other.has_colonization_orders then
            has_colonization_orders := True
        end
        if other.has_engage_orders then
            has_engage_orders := True
        end
        other.clear_ships
        scanner_range := 0
        recalculate_current_speed
    ensure
        ship_count >= old ship_count
        ship_count <= old ship_count + old other.ship_count
    end

    split(sh: ITERATOR [like ship_type]) is
        -- Removes ships in`sh' from current fleet, and returns a 
        -- fleet with those ships, and the same
        -- `owner', `orbit_center', `destination' and `eta' as Current.
    require
        sh /= Void
        -- sh.for_all (agent has_ship (?.id))
    do
        !!splitted_fleet.make
        splitted_fleet.move_to (Current)
        splitted_fleet.set_destination(destination)
        splitted_fleet.set_eta(eta)
        splitted_fleet.set_owner(owner)
        if orbit_center /= Void then
            splitted_fleet.set_orbit_center (orbit_center)
        end
        from until sh.is_off loop
            remove_ship(sh.item)
            splitted_fleet.add_ship(sh.item)
            sh.next
        end
        scanner_range := 0
        recalculate_current_speed
        splitted_fleet.recalculate_current_speed
    ensure
        same_fleet: (splitted_fleet.eta = eta) and
                    (splitted_fleet.owner = owner) and
                    (splitted_fleet.destination = destination) and
                    (splitted_fleet.orbit_center = orbit_center)
        ship_conservation: splitted_fleet.ship_count + ship_count = old ship_count
    end

    enter_orbit (star: like orbit_center) is
        -- Put fleet in orbit around `star'
    require
        star /= Void
        not is_in_orbit
    do
        move_to (star)
        orbit_center := star
        eta := 0
        destination := Void
    ensure
        is_in_orbit and orbit_center = star
    end

    leave_orbit is
        -- Abandon orbit
    require
        is_in_orbit
    do
        orbit_center := Void
        has_colonization_orders := False
        has_engage_orders := False
    ensure
        not is_in_orbit
    end

    move is
    do
        -- Departure
        if is_in_orbit and not is_stopped then
            recalculate_eta
            leave_orbit
        end
        -- Travel
        check not is_stopped = not is_in_orbit end
        if destination /= Void then
            -- This should evolve in to a more complex calculation
            -- Involving modifiers like nebulae, or enemies' 
            -- warp dissipators
            move_towards (destination, current_speed)
            eta := (eta - 1).max(0)
        end
        -- Arrival
        if eta = 0 and not is_stopped then
            enter_orbit (destination)
            owner.add_to_known_list (orbit_center)
            owner.add_to_visited_list (orbit_center)
            orbit_center.collect_special(owner)
        end
    end

feature -- Operations

    copy_from (f: like Current) is
        -- Copies all information from `f', except ship list
    do
        owner := f.owner
        destination := f.destination
        eta := f.eta
        id := f.id
        orbit_center := f.orbit_center
        x := f.x
        y := f.y
        scanner_range := 0
    end

    set_eta (e: INTEGER) is
    require
        valid_eta: e >= 0
    do
        eta := e
    ensure
        eta = e
    end

    recalculate_eta is
    require
        not is_stopped
        current_speed > 0
    do
        eta := eta_at(destination)
    ensure
        valid_eta: eta >= 0
    end

    recalculate_current_speed is
        -- Very dumb for now.
    do
        current_speed := owner.drive_speed
    ensure
        current_speed > 0
    end

    set_destination (d: like destination) is
    do
        destination := d
        if destination = orbit_center then destination := Void end
        if destination /= Void then
            has_colonization_orders := False
            has_engage_orders := False
        end
    ensure
        d /= orbit_center implies destination = d
    end

    set_owner (o: like owner) is
    do
        owner := o
        scanner_range := 0
    ensure
        owner = o
    end

feature -- Access -- Giving Orders

    has_colonization_orders: BOOLEAN
        -- has this fleet received orders of colonizing

    can_colonize: BOOLEAN is
        -- Can this fleet colonize a planet?
    local
        it: ITERATOR[SHIP]
    do
        from
            it := ships.get_new_iterator_on_items
        until
            Result or it.is_off
        loop
            Result := it.item.can_colonize
            it.next
        end
    end

    has_engage_orders: BOOLEAN
        -- has this fleet received orders of attacking

    can_engage: BOOLEAN is
        -- Can this fleet engage enemy fleets?
    local
        it: ITERATOR[SHIP]
    do
        from
            it := ships.get_new_iterator_on_items
        until
            Result or it.is_off
        loop
            Result := it.item.can_attack
            it.next
        end
    end

    will_engage: like owner
        -- Player to be engaged at the end of the turn

    will_engage_at: PLANET
        -- Place to engage enemy

feature -- Operations -- Receiving orders

    colonize_order is
    require
        can_colonize
    do
        has_colonization_orders := True
    ensure
        has_colonization_orders
    end

    cancel_colonize_order is
    do
        has_colonization_orders := False
    end

    engage_order is
    require
        can_engage
    do
        has_engage_orders := True
    ensure
        has_engage_orders
    end

    set_engagement (enemy: like will_engage; location: like will_engage_at) is
    require
        enemy /= owner
        location /= Void implies location.colony.owner = enemy
    do
        will_engage := enemy
        will_engage_at := location
    end

    cancel_engage_order is
    do
        has_engage_orders := False
    end

feature -- Combat

    offensive_power: INTEGER is
    local
        i: ITERATOR [SHIP]
    do
        from i := get_new_iterator until i.is_off loop
            if i.item.can_attack then Result := Result + 1 end
            i.next
        end
    end

    damage (amount: INTEGER) is
    require
        amount >= 0
    local
        left: INTEGER
        fighters: INTEGER
    do
        from
            fighters := offensive_power
            left := amount
        until fighters = 0 or left = 0 loop
            take_hit
            fighters := fighters - 1
            left := left - 1
        end
        if fighters = 0 then
            -- Fleet destroyed
            from until ships.count = 0 loop
                remove_ship (ships.item (ships.lower))
            end
        end
    end

    take_hit is
        -- Remove fighter from fleet
    local
        i: ITERATOR [like ship_type]
    do
        from i := get_new_iterator until
            i.is_off or else i.item.can_attack
        loop
            i.next
        end
        if not i.is_off then remove_ship (i.item) end
    end

feature {GALAXY} -- Scanning

    scan(alienfleet: like Current; alienship: like ship_type): BOOLEAN is
        -- Returns true if this fleet picks up `alienship' with it's 
        -- scanners.  `alienship' is part of `alienfleet'
    require
        alienfleet.has_ship(alienship.id)
    do
        if scanner_range = 0 then
            recalculate_scanner_range
        end

        if owner.race.omniscient then
            Result := True
        else
            if Current |-| alienfleet < (scanner_range + alienship.size - alienship.ship_size_frigate).to_real then
                Result := True
            end
        end
    end

feature {NONE} -- Auxiliary for scanning

    scanner_range: INTEGER
        -- Scanner range considering all our fleet's modifiers.  
        -- Should be reset to 0 after any modification (joining, 
        -- splitting, leader assignment, etc.).

    recalculate_scanner_range is
        -- Recalculates `scanner_range' considering all our modifiers.
        -- Quite dumb for now...
    do
        scanner_range := 2
    end

feature {NONE} -- Creation

    make is
    do
        make_unique_id
        !!ships.make
        current_speed := 1.0
    end

feature {FLEET} -- Representation

    ships: HASHED_DICTIONARY [like ship_type, INTEGER]
        -- Ships, indexed by id

feature -- Anchors

    ship_type: SHIP

invariant
    orbiting_really_here: is_in_orbit implies distance_to (orbit_center) = 0
    nonnegative_speed: current_speed >= 0
    nonnegative_eta: eta >= 0
    positive_speed: current_speed > 0
    has_colonization_orders implies orbit_center /= Void
    has_engage_orders implies orbit_center /= Void
end -- class FLEET
