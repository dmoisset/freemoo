deferred class SHIP
    -- base class for SHIPs

inherit
    SHIP_CONSTANTS
    HASHABLE

feature -- Hashing function
    hash_code: INTEGER is
    do
        Result := id
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

    id: INTEGER

feature {NONE} -- Creation
    make is
    do
        id := counter.value
        counter.increment
    end

feature -- Modifiers
    is_stealthy: BOOLEAN

feature -- Implementarion
    counter: COUNTER is
    once
        !!Result
    end


invariant
    size.in_range(1, 6)

end -- class SHIP