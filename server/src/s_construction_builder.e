class S_CONSTRUCTION_BUILDER

inherit
    CONSTRUCTION_BUILDER
    redefine
        last_ship
    end

creation make

feature -- Access

    last_ship: S_SHIP_CONSTRUCTION

end -- class S_CONSTRUCTION_BUILDER
