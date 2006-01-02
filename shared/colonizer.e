class COLONIZER
--
-- Something that can colonize planets
--

inherit
    UNIQUE_ID

feature -- Access

    owner: PLAYER

    has_colonization_orders: BOOLEAN
        -- Will we colonize at the end of this turn

    planet_to_colonize: PLANET
        -- Planet on which we shall establish a colony

feature -- Operations

    set_colonization_orders(will_colonize: BOOLEAN) is
    do
        has_colonization_orders := will_colonize
        if not will_colonize then
            planet_to_colonize := Void
        end
    ensure
        has_colonization_orders = will_colonize
    end

    set_planet_to_colonize(p: like planet_to_colonize) is
    require
        p /= Void
        p.is_colonizable
    do
        planet_to_colonize := p
    ensure
        planet_to_colonize = p
    end

    colonize is
    require
        planet_to_colonize /= Void
        planet_to_colonize.is_colonizable
    local
        c: COLONY
    do
        c := planet_to_colonize.create_colony(owner)
        planet_to_colonize:= Void
    end

end -- class COLONIZER
