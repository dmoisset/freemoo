class S_CONSTRUCTION_BUILDER

inherit
    CONSTRUCTION_BUILDER
    redefine
        last_ship, last_android, starship_type
    end
    SERVER_ACCESS

feature -- Access

    last_ship: S_SHIP_CONSTRUCTION

    last_android: S_CONSTRUCTION_ANDROID

feature {NONE} -- Anchors

    starship_type: S_STARSHIP

end -- class S_CONSTRUCTION_BUILDER
