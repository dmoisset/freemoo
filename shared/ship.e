deferred class SHIP
    -- base class for SHIPs

inherit
    SHIP_CONSTANTS
    UNIQUE_ID


feature {NONE} -- Creation

    make (p: like creator) is
    require
        p /= Void
    do
        creator := p
        owner := p
        picture := 0
        make_unique_id
    end

feature -- Access

    creator: PLAYER
        -- Player that built Current

    owner: like creator
        -- Player that controls Current

    size: INTEGER is
        -- Ship size.  Use commodity ship_size* values
    deferred
    end

    picture: INTEGER
        -- icon for ship

    ship_type: INTEGER is
        -- An Identifier for different type of ships.
    deferred
    end

    as_colony_ship: COLONY_SHIP is
    require
        can_colonize
    deferred
    ensure
        -- This gives a warning, SmartEiffel is too smart here :)
        -- but it is true anyway, when the precondition is satisfied
        -- Result = Current
    end

feature -- Operations

    set_picture (p: INTEGER) is
    do
        picture := p
    ensure
        picture = p
    end

    set_owner (o: like owner) is
    require
        o /= Void
    do
        owner := o
    end

feature -- Modifiers

    is_stealthy: BOOLEAN is
    do
        Result := owner.race.stealthy
        -- Also consider stealth technology here
    end

    can_colonize: BOOLEAN is
        -- True for colony ships with no given colonize orders
    deferred
    end

    can_attack: BOOLEAN is
        -- True for non-support ships
    deferred
    end

    fuel_range: REAL is
        -- Relative to players base fuel range:
        --   1 for normal ships
        --   1.5 for extra fuel tanks or colony ships
    deferred
    end

invariant
    size.in_range(ship_size_min, ship_size_max)
    ship_type.in_range(ship_type_min, ship_type_max)
    fuel_range > 0
    creator /= Void
    owner /= Void

end -- class SHIP
