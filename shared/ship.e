class SHIP
    -- base class for SHIPs

inherit
    SHIP_CONSTANTS
    UNIQUE_ID

creation make

feature {NONE} -- Creation

    make(p: PLAYER) is
		do
			creator := p
			owner := p
			size := 1
			picture := 0
			make_unique_id
		end

feature -- Access

    creator: PLAYER
        -- Player that built Current

    owner: PLAYER
        -- Player that controls Current

    size: INTEGER
        -- Ship size.  Use commodity ship_size* values

    picture: INTEGER
        -- icon for ship

feature -- Operations

    set_size (s:INTEGER) is
    require
        s.in_range(1, 6)
    do
        size := s
    ensure
        size = s
    end

    set_picture (p:INTEGER) is
    do
        picture := p
    ensure
        picture = p
    end

feature -- Modifiers
    is_stealthy: BOOLEAN

invariant
    size.in_range(1, 6)

end -- class SHIP
