class FLEET
    -- Group of SHIPs moving together

inherit
    POSITIONAL
    ORBITING

creation
    make

feature -- Access

    owner: PLAYER
        -- Player that controls Current

    orbiting: STAR
        -- Star being orbited, Void iff none

    is_in_orbit: BOOLEAN is
        -- Is in orbit around a star?
    do
        Result := orbiting /= Void
    ensure
        Result = (orbiting /= Void)
    end

    destination: STAR
        -- Star where to which the fleet is traveling, or Void if none

    eta: INTEGER
        -- Estimated time of arrival when traveling, 0 when not

    is_stopped: BOOLEAN is
        -- is fleet stopped?
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

    enter_orbit (star: STAR) is
        -- Put fleet in orbit around `star'
    require
        star /= Void
        not is_in_orbit
    do
        move_to (star)
        orbiting := star
        eta := 0
        current_speed := 0
        destination := Void
    ensure
        is_in_orbit and orbiting = star
    end

    leave_orbit is
        -- Abandon orbit
    require
        is_in_orbit
    do
        orbiting := Void
    ensure
        not is_in_orbit
    end

    move is
    do
        -- Departure
        if is_in_orbit and not is_stopped then
            current_speed := speed (orbiting, destination)
            eta := ((orbiting |-| destination) / current_speed).ceiling
            leave_orbit
        end
        -- Travel
        check not is_stopped = not is_in_orbit end
        eta := (eta - 1).max (0)
        move_towards (destination, current_speed)
        -- Arrival
        if eta = 0 and not is_stopped then
            enter_orbit (destination)
        end
    end

feature {NONE} -- Creation
    make is
    do
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
    orbiting_really_here: is_in_orbit implies distance_to (orbiting) = 0

    reachable_destination:
        (is_in_orbit and destination /= Void)
    implies
        speed (orbiting, destination) > 0

    nonnegative_speed: current_speed >= 0
    nonnegative_eta: eta >= 0
    stopped_iff_not_travelling: (destination = Void) = (current_speed = 0)
    eta0_iff_not_travelling: (destination = Void) = (eta = 0)

end -- class FLEET