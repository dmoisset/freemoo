class STARSHIP
    -- Combat capable ship

inherit
    SHIP
    redefine make end

creation
    make, from_design

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

    from_design(design: like Current) is
    do
        name := design.name
        creator := design.creator
        owner := design.owner
        size := design.size
        picture := design.picture
        fuel_range := design.fuel_range
        make_unique_id
        set_starship_attributes
    end

invariant
    not can_colonize
end -- class STARSHIP
