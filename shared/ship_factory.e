class SHIP_FACTORY
    -- Abstract factory for ships

inherit
    SHIP_CONSTANTS

feature -- Access

    last_starship: STARSHIP

    last_colony_ship: COLONY_SHIP

    last_ship: SHIP

    default_owner: PLAYER

feature -- Operations

    set_default_owner(owner: like default_owner) is
    do
        default_owner := owner
    ensure
        default_owner = owner
    end

    create_starship(owner: like default_owner) is
    require
        owner /= Void or default_owner /= Void
    local
        p: like default_owner
        sh: like last_starship
    do
        if owner = Void then p := default_owner else p := owner end
        create sh.make(owner)
        last_ship := sh
        last_starship := sh
    ensure
        last_starship /= Void
        last_ship /= Void
    end

    create_colony_ship(owner: like default_owner) is
    require
        owner /= Void or default_owner /= Void
    local
        p: like default_owner
        sh: like last_colony_ship
    do
        if owner = Void then p := default_owner else p := owner end
        create sh.make(owner)
        last_ship := sh
        last_colony_ship := sh
    ensure
        last_colony_ship /= Void
        last_ship /= Void
    end

    create_by_type(type: INTEGER; owner: like default_owner) is
    require
        type.in_range(ship_type_min, ship_type_max)
        owner /= Void or default_owner /= Void
    local
        p: like default_owner
        starship: like last_starship
        colony_ship: like last_colony_ship
    do
        if owner = Void then p := default_owner else p := owner end
        inspect type
            when ship_type_colony_ship then
                create colony_ship.make(owner)
                last_colony_ship := colony_ship
                last_ship := colony_ship
            when ship_type_starship then
                create starship.make(owner)
                last_starship := starship
                last_ship := starship
        end
    ensure
        last_ship /= Void
    end

end -- class SHIP_FACTORY
