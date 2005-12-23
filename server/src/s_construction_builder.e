class S_CONSTRUCTION_BUILDER

inherit
    CONSTRUCTION_BUILDER
    redefine
        last_ship, starship_type
    end

feature -- Access

    last_ship: S_SHIP_CONSTRUCTION

feature {NONE} -- Anchors

    starship_type: S_STARSHIP

end -- class S_CONSTRUCTION_BUILDER
