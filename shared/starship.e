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

    can_attack: BOOLEAN is True

    can_colonize: BOOLEAN is False

    ship_type: INTEGER is do Result := ship_type_starship end

    fuel_range: REAL is 1.0

    size: INTEGER

feature -- Operations

    set_name(new_name: STRING) is
    do
        name := new_name
    ensure
        name = new_name
    end

    set_size (s: INTEGER) is
    require
        s.in_range(ship_size_min, ship_size_max)
    do
        size := s
    ensure
        size = s
    end

feature {NONE} -- Creation

    from_design(design: like Current) is
    do
        name := design.name
        creator := design.creator
        owner := design.owner
        size := design.size
        picture := design.picture
        make_unique_id
    end

    make (p: like creator) is
    do
        Precursor (p)
        size := 1
    end

invariant
    not can_colonize
end -- class STARSHIP
