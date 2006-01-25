class CONSTRUCTION_ARTIFICIAL_PLANET

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
                      p.item.type /= p.item.type_planet
            p.next
        end
    end

    cost(c: like colony_type): INTEGER is
    do
        Result := 800
    end

    build(c: like colony_type) is
    local
        p: ITERATOR[PLANET]
    do
        from
            p := c.location.orbit_center.get_new_iterator_on_planets
        until
            p.is_off or else (p.item /= Void and then p.item.type /= p.item.type_planet)
        loop
            p.next
        end
        if not p.is_off then
            if p.item.type = p.item.type_gasgiant then
                p.item.set_size(p.item.plsize_huge)
            else
                check p.item.type = p.item.type_asteroids end
                p.item.set_size(p.item.plsize_large)
            end
            p.item.set_type(p.item.type_planet)
            p.item.set_climate(p.item.climate_barren)
            p.item.set_mineral(p.item.mnrl_abundant)
            p.item.set_special(p.item.plspecial_nospecial)
            p.item.set_gravity(p.item.grav_normalg)
        end
    end

    take_down(c: like colony_type) is
    do
    ensure
        False -- You can't take down an artificial planet
    end

feature {NONE} -- Creation

    make is
    do
        id := product_artificial_planet
        name := l("Artificial Planet")
        description := no_description
    end


end -- CONSTRUCTION_ARTIFICIAL_PLANET
