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
        -- one of ship_size_* constants

    picture: INTEGER
        -- icon for ship

    id: INTEGER

feature {NONE} -- Creation
    make is
    do
        id := counter.value
        counter.increment
    end

feature -- Implementarion
    counter: COUNTER is
    once
        !!Result
    end


invariant
    size.in_range(ship_size_min, ship_size_max)

end -- class SHIP