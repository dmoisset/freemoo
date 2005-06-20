class SHIP
    -- base class for SHIPs

inherit
    SHIP_CONSTANTS
    UNIQUE_ID
    select id end


creation make

feature {NONE} -- Creation

    make(p: like creator) is
    require p /= Void
    do
        creator := p
        owner := p
        size := 1
        picture := 0
        fuel_range := 1.0
        make_unique_id
    end

feature -- Access

    creator: PLAYER
        -- Player that built Current

    owner: like creator
        -- Player that controls Current

    size: INTEGER
        -- Ship size.  Use commodity ship_size* values

    picture: INTEGER
        -- icon for ship

    ship_type: INTEGER
        -- An Identifier for different type of ships.

feature -- Operations

    set_size (s: INTEGER) is
    require
        s.in_range(ship_size_min, ship_size_max)
    do
        size := s
    ensure
        size = s
    end

    set_picture (p: INTEGER) is
    do
        picture := p
    ensure
        picture = p
    end

feature -- Modifiers
    is_stealthy: BOOLEAN

    can_colonize: BOOLEAN
        -- True for colony ships

    fuel_range: REAL
        -- Relative to players base fuel range:
        --   1 for normal ships
        --   1.5 for extra fuel tanks or colony ships

invariant
    size.in_range(ship_size_min, ship_size_max)
    ship_type.in_range(ship_type_min, ship_type_max)
    fuel_range > 0
    creator /= Void
    owner /= Void

end -- class SHIP
