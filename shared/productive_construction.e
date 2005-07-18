class PRODUCTIVE_CONSTRUCTION

inherit
    CONSTRUCTION

creation make

feature -- Access

    name: STRING

    can_be_built_on(c: COLONY):BOOLEAN is
    do
        Result := not c.constructions.fast_has(Current)
    end

    cost(c: COLONY): INTEGER is
    do
        Result := base_cost
    end

    maintenance: INTEGER 

feature -- Operations

    set_farming_bonuses(prop, fixed: INTEGER) is
    do
        farming_proportional := prop
        farming_fixed := fixed
    end

    set_industry_bonuses(prop, fixed: INTEGER) is
    do
        industry_proportional := prop
        industry_fixed := fixed
    end


    set_science_bonuses(prop, fixed: INTEGER) is
    do
        science_proportional := prop
        science_fixed := fixed
    end

    set_cost(c: INTEGER) is
    do
        base_cost := c
    ensure
        base_cost = c
    end

    set_maintenance(m: INTEGER) is
    do
        maintenance := m
    ensure
        maintenance = m
    end

    produce_proportional(c: COLONY) is
    do
        c.farming.add(farming_proportional, name)
        c.industry.add(industry_proportional, name)
        c.science.add(science_proportional, name)
    end

    produce_fixed(c: COLONY) is
    do
        c.farming.add(farming_fixed, name)
        c.industry.add(industry_fixed, name)
        c.science.add(science_fixed, name)
    end

    clean_up_pollution(c: COLONY) is
    do
    end

    build(c: COLONY) is
    do
    end

    take_down(c: COLONY) is
    do
    end

feature {NONE} -- Implementation

    farming_fixed, farming_proportional: INTEGER

    industry_fixed, industry_proportional: INTEGER

    science_fixed, science_proportional: INTEGER

    base_cost: INTEGER

feature {NONE} -- Creation

    make(n: STRING) is
    require
        n /= Void
    do
        name := n
    ensure
        name = n
    end

end
