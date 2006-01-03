class CONSTRUCTION_COLONY_BASE

inherit
    CONSTRUCTION
        rename
            make as construction_make
        redefine
            can_be_built_on, cost, build, take_down
        end
    GETTEXT

create
    make

feature

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
        name := l("Colony Base")
        description := l("Creates a colony on another planet inside the same star system as the building colony.")
    end

end -- class CONSTRUCTION_COLONY_BASE
