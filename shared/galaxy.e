class GALAXY

creation make

feature {NONE} -- Creation

    make is
    do
        !!stars.with_capacity (256, 1)
        !!ships.make
    end

feature -- Access

    stars: ARRAY [STAR]
        -- stars in the map, by id

    ships: DICTIONARY [SHIP, INTEGER]
        -- All the active ships, indexed by id

feature -- Operations

    add_ship (item: SHIP) is
        -- Add new ship
    do
        ships.put (item, next_id)
        next_id := next_id + 1
    end

feature {NONE} -- Representation

    next_id: INTEGER
        -- Id for the next ship to add

invariant
    stars /= Void
    ships /= Void

end -- class GALAXY