class COLONY_SHIP
    -- Ships capable of founding new colonies

inherit
    SHIP
        redefine owner, make end
    COLONIZER
        redefine
            owner, set_planet_to_colonize, colonize
        end
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

feature -- Access

    owner: like creator

    as_colony_ship: COLONY_SHIP is
    do
        Result := Current
    end

feature -- Operations

    set_planet_to_colonize(p: like planet_to_colonize) is
    do
        Precursor(p)
        can_colonize := planet_to_colonize = Void
    end

    colonize is
    do
        Precursor
        can_colonize := True
    end

end -- class COLONY_SHIP
