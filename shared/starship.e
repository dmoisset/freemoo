class STARSHIP
    -- Combat capable ship

inherit
    SHIP
    redefine make end

creation
    make

feature -- Access

    name: STRING

    as_colony_ship: COLONY_SHIP is
    do
        -- No implementation needed, precondition is always False
        -- (see invariant below)
    end

feature -- Operations

    set_name(new_name: STRING) is
    do
        name := new_name
    ensure
        name = new_name
    end

feature {NONE} -- Creation

    make(p: like creator) is
    do
        Precursor(p)
        set_starship_attributes
    end

    set_starship_attributes is
    do
        can_attack := True
        ship_type := ship_type_starship
    end

invariant
    not can_colonize
end -- class STARSHIP
