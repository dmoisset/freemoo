deferred class SHIP
    -- Base class for ships

inherit
    POSITIONAL
    ORBITING

feature -- Access

    creator: PLAYER
        -- Player that built Current

    owner: PLAYER is
        -- Player to whom Current responds
    do
        Result := creator
    end

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
        -- Star where the ship will travel, or Void if none

    is_stopped: BOOLEAN is
        -- is ship stopped?
    do
        Result := destination = Void
    ensure
        Result = (destination = Void)
    end

feature -- Operations

    enter_orbit (star: STAR) is
        -- Put ship in orbit around `star'
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

feature {NONE} -- Internal

    current_speed: REAL
        -- Current travel speed, 0 if in orbit

    eta: INTEGER
        -- Estimated time of arrival when traveling, 0 when not

    speed (origin, dest: STAR): REAL is
        -- Travel speed from `origin' to `dest'
    do
        Result := 1.0
    ensure
        Result >= 0
    end

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

end -- class SHIP