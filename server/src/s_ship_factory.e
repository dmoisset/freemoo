class S_SHIP_FACTORY
    -- Concrete ship factory for creating S_SHIPs

inherit
    SHIP_FACTORY
    redefine
        last_starship, last_colony_ship, last_ship, default_owner
    end

feature -- Access

    last_starship: S_STARSHIP

    last_colony_ship: S_COLONY_SHIP

    last_ship: S_SHIP

    default_owner: S_PLAYER

end -- class S_SHIP_FACTORY
