class COLONY

inherit
    UNIQUE_ID

creation make

feature {NONE} -- Creation

    make (p: PLANET; o: PLAYER) is
        -- Build `o' colony on planet `p'
    require
        p /= Void
    do
        make_unique_id
        producing := product_none
        location := p
        p.set_colony (Current)
        owner := o
        o.add_colony (Current)
    ensure
        location = p
        p.colony = Current
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
            !STARSHIP!sh.make
        when product_colony_ship then
            !COLONY_SHIP!sh.make
        end
-- This should add to the local fleet. Fix
--        if sh /= Void then -- Ship produced
--            location.add_ship (sh)
--            sh.enter_orbit (location.orbit_center)
--        end
    end

feature -- Operations

    set_producing (newproducing: INTEGER) is
    require newproducing.in_range(product_min, product_max)
    do
        producing := newproducing
    ensure
        producing = newproducing
    end

invariant
    valid_producing: producing.in_range (product_min, product_max)
    location /= Void
    owner /= Void

end -- class COLONY