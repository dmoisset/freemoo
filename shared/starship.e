class STARSHIP
    -- Combat capable ship

inherit
    SHIP

creation
    make, from_design

feature -- Access

    name: STRING

    as_colony_ship: COLONY_SHIP is
    do
        -- No implementation needed, precondition is always False
        -- (see invariant below)
    end

    can_attack: BOOLEAN is True

    can_colonize: BOOLEAN is False

    ship_type: INTEGER is do Result := ship_type_starship end

feature -- Operations

    set_name(new_name: STRING) is
    do
        name := new_name
    ensure
        name = new_name
    end

feature {NONE} -- Creation

    from_design(design: like Current) is
    do
        name := design.name
        creator := design.creator
        owner := design.owner
        size := design.size
        picture := design.picture
        fuel_range := design.fuel_range
        make_unique_id
    end

invariant
    not can_colonize
end -- class STARSHIP
