class CONSTRUCTION_COLONY_BASE

inherit
    CONSTRUCTION
    GETTEXT

create
    make

feature

    name: STRING is
    do
        Result := l("Colony Base")
    end

    can_be_built_on(c: like colony_type): BOOLEAN is
    local
        p: ITERATOR[PLANET]
    do
        from
            p := c.location.orbit_center.get_new_iterator_on_planets
        until
            Result or p.is_off
        loop
            Result := p.item /= Void and then
                      p.item.type = p.item.type_planet and then
                      p.item.colony = Void
            p.next
        end
    end

    produce_proportional, produce_fixed, generate_money,
    clean_up_pollution(c: like colony_type) is
    do
    end

    maintenance(c: like colony_type): INTEGER is
    do
    end

    cost(c: like colony_type): INTEGER is
    do
        Result := 200
    end

    build(c: like colony_type) is
    do
        c.set_colonization_orders(True)
    end

    take_down(c: like colony_type) is
    do
    ensure
        False -- Colony bases shouldn't be taken down like this
    end

feature {NONE} -- Creation

    make is
    do
        id := product_colony_base
        description := "Creates a colony on another planet inside the same star system as the building colony."
    end

end -- class CONSTRUCTION_COLONY_BASE
