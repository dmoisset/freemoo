class COLONY_SHIP
    -- Ships capable of founding new colonies

inherit
    SHIP
        redefine owner, make end
    COLONIZER
        redefine
            owner
        end

create
    make

feature {NONE} -- Creation

    make(p: like creator) is
    do
        Precursor(p)
        set_colony_ship_attributes
    end

    set_colony_ship_attributes is
    do
        fuel_range := 1.5
        size := ship_size_special
    end

feature -- Access

    owner: like creator

    as_colony_ship: COLONY_SHIP is
    do
        Result := Current
    end

    can_attack: BOOLEAN is False

    can_colonize: BOOLEAN is
    do
        Result := planet_to_colonize = Void
    end

    ship_type: INTEGER is do Result := ship_type_colony_ship end

invariant
    not_capturable: creator = owner

end -- class COLONY_SHIP
