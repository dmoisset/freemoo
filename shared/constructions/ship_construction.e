class SHIP_CONSTRUCTION

inherit
    CONSTRUCTION
    redefine
        can_be_built_on, cost, build, name
    end
    GETTEXT

creation
    make_starship, make_colony_ship, make_transport, make_outpost

feature -- Access

    name: STRING

    can_be_built_on(c: like colony_type): BOOLEAN is
    do
        -- Large ships can't be built on colonies without a starbase or
        -- equivalent, but we don't have star bases yet.
        Result := True
    end

    cost(c: like colony_type): INTEGER is
    do
        if id = product_colony_ship then
            Result := 500
        else
            Result := starship_cost
        end
    end

    design: STARSHIP

feature -- Operations

    build(c: like colony_type) is
    do
        if id = product_colony_ship then
            ship_factory.create_colony_ship(c.owner)
            c.build_ship(ship_factory.last_colony_ship)
        else
            c.build_ship(design)
        end
    end

feature {NONE} -- Implementation

    starship_cost: INTEGER is
        -- Calculate cost from ship design!
    do
        Result := 40
    end

feature {NONE} -- Creation

    make_colony_ship is
    do
        id := product_colony_ship
        name := l("Colony Ship")
    end

    make_starship(new_design: like design) is
    do
        id := product_max + new_design.id
        design := new_design
    end

feature {NONE} -- Auxiliar

    ship_factory: SHIP_FACTORY

invariant

    id > product_max implies design /= Void

end -- class SHIP_CONSTRUCTION
