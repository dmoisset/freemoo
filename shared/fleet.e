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

    destination: STAR
        -- Star where to which the fleet is traveling, or Void if none

    eta: INTEGER
        -- Estimated time of arrival when traveling, 0 when not

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
    
    ship (sid: INTEGER): SHIP is
        -- Ship in this fleet with id `sid'
    require
        has_ship (sid)
    do
        Result := ships @ sid
    end
    
    get_new_iterator: ITERATOR[SHIP] is
        -- Returns an iterator on the fleet's ships
    do
        Result:= ships.get_new_iterator_on_items
    end

    splitted_fleet: FLEET

feature -- Operations

    add_ship (s: SHIP) is
        -- Add `s' to fleet
    do
        ships.put (s, s.id)
    ensure
        has_ship (s.id)
    end

    remove_ship (s: SHIP) is
        -- Remove `s' from fleet
    do
        ships.remove(s.id)
    ensure
        not has_ship(s.id)
    end

    join (other: FLEET) is
        -- Join up with another fleet
    require
        other /= Void
    do
        ships.union(other.ships)
    ensure
        ship_count >= old ship_count
        ship_count <= old ship_count + other.ship_count
    end

    split(shs: SET[SHIP]) is
        -- Removes `ships' from current fleet, and returns a fleet with
        -- those ships from `ships' that were in Current, and the same
        -- `owner', `orbit_center', `destination' and `eta' as Current.
    require
        shs /= Void
--        shs.for_all (agent has_ship (?.id))
    local
        sh: ITERATOR[SHIP]
    do
        !!splitted_fleet.make
        splitted_fleet.move_to (Current)
        splitted_fleet.set_orbit_center(orbit_center)
        splitted_fleet.set_destination(destination)
        splitted_fleet.set_eta(eta)
        splitted_fleet.set_owner(owner)
        from sh := shs.get_new_iterator
        until sh.is_off
        loop
            remove_ship(sh.item)
            splitted_fleet.add_ship(sh.item)
            sh.next
        end
    ensure
        same_fleet: (splitted_fleet.eta = eta) and 
                    (splitted_fleet.owner = owner) and
                    (splitted_fleet.destination = destination) and 
                    (splitted_fleet.orbit_center = orbit_center)
        ship_conservation: splitted_fleet.ship_count + ship_count = old ship_count
        splitted_fleet.ship_count = shs.count
    end

    enter_orbit (star: STAR) is
        -- Put fleet in orbit around `star'
    require
        star /= Void
        not is_in_orbit
    do
        move_to (star)
        orbit_center := star
        eta := 0
        current_speed := 0
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
    ensure
        not is_in_orbit
    end

    move is
    do
        -- Departure
        if is_in_orbit and not is_stopped then
            current_speed := speed (orbit_center, destination)
            eta := ((orbit_center |-| destination) / current_speed).ceiling
            leave_orbit
        end
        -- Travel
            check not is_stopped = not is_in_orbit end
        eta := (eta - 1).max (0)
        if destination /= Void then
            move_towards (destination, current_speed)
        end
        -- Arrival
        if eta = 0 and not is_stopped then
            enter_orbit (destination)
            owner.add_to_known_list (orbit_center)
            owner.add_to_visited_list (orbit_center)
        end
    end

    set_eta (e: INTEGER) is
    require
        valid_eta: e >= 0
    do
        eta := e
    ensure
        eta = e
    end

    set_destination (d: STAR) is
    do
        destination := d
    ensure
        destination = d
    end

    set_owner (o: PLAYER) is
    do
        owner := o
    ensure
        owner = o
    end

feature {NONE} -- Creation

    make is
    do
        make_unique_id
        !!ships.make
    end

feature {NONE} -- Internal

    current_speed: REAL
        -- Current travel speed, 0 if in orbit

    speed (origin, dest: STAR): REAL is
        -- Travel speed from `origin' to `dest'
    do
        Result := 1.0
    ensure
        Result >= 0
    end

feature {FLEET} -- Representation

    ships: DICTIONARY [SHIP, INTEGER]
        -- Ships, indexed by id

invariant
    orbiting_really_here: is_in_orbit implies distance_to (orbit_center) = 0

    reachable_destination:
        (is_in_orbit and destination /= Void)
    implies
        speed (orbit_center, destination) > 0

    nonnegative_speed: current_speed >= 0
    nonnegative_eta: eta >= 0
    is_stopped implies current_speed = 0

end -- class FLEET
