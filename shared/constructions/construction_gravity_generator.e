class CONSTRUCTION_GRAVITY_GENERATOR

inherit
    CONSTRUCTION
    GETTEXT

create
    make

feature

    name: STRING is
    do
        Result := l("Planetary Gravity Generator")
    end

    can_be_built_on(c: like colony_type): BOOLEAN is
    do
        Result := not c.constructions.has(id) and then
                  c.location.gravity /= c.owner.race.homeworld_gravity
                                        + c.location.grav_normalg
    end

    produce_proportional, produce_fixed, generate_money,
    clean_up_pollution(c: like colony_type) is
    do
    end

    maintenance(c: like colony_type): INTEGER is
    do
        Result := 2
    end

    cost(c: like colony_type): INTEGER is
    do
        Result := 120
    end

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
        description := "Creates artificial gravity to normalize a planet to standard gravity limits. Gravity generators eliminate the negative effects of low and heavy gravity fields."
    end



end -- class CONSTRUCTION_GRAVITY_GENERATOR
