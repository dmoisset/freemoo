class COLONY

creation make

feature {NONE} -- Creation

    make (p: PLANET) is
        -- Build colony on planet `p'
    require
        p /= Void
    do
        location := p
        producing := product_none
    ensure
        location = p
        producing = product_none
    end

feature -- Access

    producing: INTEGER
        -- Item being produced, one of the `product_xxxx' constants.

    location: PLANET
        -- location of the colony

    owner: PLAYER
        -- Player that controls the colony

feature -- Constants

    product_none,
    product_starship,
    product_colony_ship: INTEGER is unique
        -- Possible production_items

    product_min: INTEGER is
        -- Minimum valid for `producing'
    do Result := product_none end

    product_max: INTEGER is
        -- Minimum valid for `producing'
    do Result := product_colony_ship end

feature -- Operations

    new_turn is
    local
        sh: SHIP
    do
        inspect
            producing
        when product_none then
            -- Nothing to do this turn
        when product_starship then
            !STARSHIP!sh
        when product_colony_ship then
            !COLONY_SHIP!sh
        end
        if sh /= Void then -- Ship produced
            location.add_ship (sh)
            sh.enter_orbit (location.orbit_center)
        end
    end

invariant
    valid_producing: producing.in_range (product_min, product_max)
    location /= Void

end -- class COLONY