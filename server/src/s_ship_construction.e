class S_SHIP_CONSTRUCTION

inherit
    SHIP_CONSTRUCTION
    redefine
        ship_factory, design, colony_type
    end

creation make_starship, make_colony_ship

feature {NONE}-- Redefined features

    ship_factory: S_SHIP_FACTORY

    colony_type: S_COLONY

    design: S_SHIP

end -- class S_SHIP_CONSTRUCTION
