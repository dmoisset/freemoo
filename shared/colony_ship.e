class COLONY_SHIP
    -- Ships capable of founding new colonies

inherit
    SHIP
    redefine make end

creation
    make

feature {NONE} -- Creation

    make(p: like creator) is
    do
        Precursor(p)
        set_colony_ship_attributes
    end

    set_colony_ship_attributes is
    do
        ship_type := ship_type_colony_ship
        can_colonize := True
        fuel_range := 1.5
    end

end -- class COLONY_SHIP