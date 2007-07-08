class COLONY_SHIP
    -- Ships capable of founding new colonies

inherit
    SHIP
        redefine owner end
    COLONIZER
        redefine
            owner
        end

create
    make

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
    ensure
        Result = (planet_to_colonize = Void)
    end

    ship_type: INTEGER is do Result := ship_type_colony_ship end

    fuel_range: REAL is 1.5

    size: INTEGER is do Result := ship_size_special end

invariant
    not_capturable: creator = owner

end -- class COLONY_SHIP
