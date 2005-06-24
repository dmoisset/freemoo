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

feature -- Access

    will_colonize: PLANET
        -- Planet on which we shall establish a colony at the end of the turn

feature -- Operations

    set_will_colonize(p: like will_colonize) is
    do
        will_colonize := p
        can_colonize := will_colonize = Void
    ensure
        will_colonize = p
    end

    colonize is
    require
        will_colonize /= Void
    do
        will_colonize.create_colony(owner)
    end    

end -- class COLONY_SHIP
