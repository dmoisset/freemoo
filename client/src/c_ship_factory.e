class C_SHIP_FACTORY
    -- Concrete ship factory for creating C_SHIPs

inherit
    SHIP_FACTORY
    redefine
        last_starship, last_colony_ship, last_ship, default_owner
    end

feature -- Access

    last_starship: C_STARSHIP

    last_colony_ship: C_COLONY_SHIP

    last_ship: C_SHIP

    default_owner: C_PLAYER

end -- class C_SHIP_FACTORY
