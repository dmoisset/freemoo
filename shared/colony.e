class COLONY

inherit
    UNIQUE_ID

creation make

feature {NONE} -- Creation

    make (p: like location; o: like owner) is
        -- Build `o' colony on planet `p'
    require
        p /= Void
        o /= Void
    do
        make_unique_id
        producing := product_none
        location := p
        p.set_colony (Current)
        owner := o
        o.add_colony (Current)
        create ship_factory
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

    shipyard: SHIP
        -- Placeholder for last built ship.  Game should come and fetch it.

    ship_factory: SHIP_FACTORY
        -- Abstract factory for ships
    
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
    do
        inspect
            producing
        when product_none then
            -- Nothing to do this turn
        when product_starship then
            ship_factory.create_starship(owner)
            ship_factory.last_starship.set_name("Enterprise")
            shipyard := ship_factory.last_starship
            set_producing(product_colony_ship)
        when product_colony_ship then
            ship_factory.create_colony_ship(owner)
            shipyard := ship_factory.last_colony_ship
            set_producing(product_starship)
        end
    end

feature -- Operations

    set_producing (newproducing: INTEGER) is
    require newproducing.in_range(product_min, product_max)
    do
        producing := newproducing
    ensure
        producing = newproducing
    end

    clear_shipyard is
        -- Clear the shipyard
    do
        shipyard := Void
    ensure
        shipyard = Void
    end
    
    serialize_on (s: SERIALIZER2) is
    do
        s.add_tuple (<<id, producing - product_min>>)
    end

    unserialize_from (s: UNSERIALIZER) is
    do
        s.get_integer
        producing := s.last_integer + product_min
    end

feature {GALAXY} -- Scanning

    scan(alienfleet: FLEET; alienship: like shipyard): BOOLEAN is
        -- Returns true if this colony picks up `alienship' with it's 
        -- scanners.  `alienship' is part of `alienfleet'
    require
        alienfleet.has_ship(alienship.id)
    do
        if scanner_range = 0 then
            recalculate_scanner_range
        end

        if owner.race.omniscient then
            Result := true
        else
            if location.orbit_center |-| alienfleet < scanner_range + alienship.size - alienship.ship_size_frigate then
                Result := true
            end
        end
    end

feature {NONE} -- Auxiliary for scanning

    scanner_range: INTEGER
        -- Scanner range considering all our colony's modifiers.  
        -- Should be reset to 0 after any modification (constructions,
        -- research, etc.).

    recalculate_scanner_range is
        -- Recalculates `scanner_range' considering all our modifiers.
        -- Quite dumb for now...
    do
        scanner_range := 2
    end

invariant
    valid_producing: producing.in_range (product_min, product_max)
    location /= Void
    owner /= Void
end -- class COLONY
