class CONSTRUCTION_GRAVITY_GENERATOR

inherit
    CONSTRUCTION
        rename
            make as construction_make
        redefine
            can_be_built_on, maintenance, cost, build, take_down
        end
    GETTEXT

create
    make

feature -- Access

    can_be_built_on(c: like colony_type): BOOLEAN is
    do
        Result := not c.constructions.has(id) and then
                  c.location.gravity /= c.owner.race.homeworld_gravity
                                        + c.location.grav_normalg
    end

    maintenance(c: like colony_type): INTEGER is
    do
        Result := 2
    end

    cost(c: like colony_type): INTEGER is
    do
        Result := 120
    end

feature -- Operations

    build(c: like colony_type) is
    do
        c.constructions.add(Current, id)
        c.set_pregrav
        c.location.set_gravity(c.location.grav_normalg +
                               c.owner.race.homeworld_gravity)
    end

    take_down(c: like colony_type) is
    do
        c.location.set_gravity(c.pregrav)
        c.constructions.remove(id)
    end

feature {NONE} -- Creation

    make is
    do
        id := product_gravity_generator
        name := l("Planetary Gravity Generator")
        description := l("Creates artificial gravity to normalize a planet to standard gravity limits. Gravity generators eliminate the negative effects of low and heavy gravity fields.")
    end

end -- class CONSTRUCTION_GRAVITY_GENERATOR
