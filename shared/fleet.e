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

    has_ship (ship: SHIP): BOOLEAN is
        -- is ship in fleet?
    do
        Result := ships.has(ship)
    ensure
        Result implies ship_count > 0
    end

    get_new_iterator: ITERATOR[SHIP] is
        -- Returns an iterator on the fleet's ships
    do
        Result:= ships.get_new_iterator
    end

feature -- Operations

    add_ship (ship: SHIP) is
        -- Add ship to fleet
    do
        ships.add(ship)
    ensure
        has_ship(ship)
    end

    remove_ship(ship:SHIP) is
        -- Remove ship from fleet
    do
        ships.remove(ship)
    ensure
        not has_ship(ship)
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

    split(shs: SET[SHIP]): FLEET is
        -- Removes `ships' from current fleet, and returns a fleet with
        -- those ships from `ships' that were in Current, and the same
        -- `owner', `orbit_center', `destination' and `eta' as Current.
    require
        shs /= Void
    local
        ship: ITERATOR[SHIP]
    do
        !!Result.make
        Result.set_orbit_center(orbit_center)
        Result.set_destination(destination)
        Result.set_eta(eta)
        Result.set_owner(owner)
        from ship := shs.get_new_iterator
        until ship.is_off
        loop
            if has_ship(ship.item) then
                remove_ship(ship.item)
                Result.add_ship(ship.item)
            end
            ship.next
        end
    ensure
        same_fleet: (Result.eta = eta) and (Result.owner = owner) and
                    (Result.destination = destination) and (Result.orbit_center = orbit_center)
        ship_conservation: Result.ship_count + ship_count = old ship_count
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
            owner.add_to_known_list (destination)
            owner.add_to_visited_list (destination)
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

    ships: SET[SHIP]

invariant
    orbiting_really_here: is_in_orbit implies distance_to (orbit_center) = 0

    reachable_destination:
        (is_in_orbit and destination /= Void)
    implies
        speed (orbit_center, destination) > 0

    nonnegative_speed: current_speed >= 0
    nonnegative_eta: eta >= 0
    stopped_iff_not_travelling: is_stopped = (current_speed = 0)

end -- class FLEET