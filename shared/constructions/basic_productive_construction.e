class BASIC_PRODUCTIVE_CONSTRUCTION
--
-- This is a basic construction that produces food, industry and/or
-- research on a colony on a fixed or per-populator basis.
-- You can build one if you don't already have one.
--

inherit
    CONSTRUCTION
    redefine
        can_be_built_on, cost, maintenance, produce_proportional,
        produce_fixed, build, take_down, name
    end

creation
    make

feature -- Access

    name: STRING

    can_be_built_on(c: like colony_type): BOOLEAN is
    do
        Result := not c.constructions.has(id)
    end

    cost(c: like colony_type): INTEGER is
    do
        Result := base_cost
    end

    maintenance(c: like colony_type): INTEGER is
    do
        Result := (base_maintenance * c.maintenance_factor).rounded
    end

feature -- Operations

    produce_proportional(c: like colony_type) is
    do
        c.farming.add(farming_proportional * (c.census @ task_farming), name)
        c.industry.add(industry_proportional * (c.census @ task_industry), name)
        c.science.add(science_proportional * (c.census @ task_science), name)
    end

    produce_fixed(c: COLONY) is
    do
        c.farming.add(farming_fixed, name)
        c.industry.add(industry_fixed, name)
        c.science.add(science_fixed, name)
    end

    build(c: COLONY) is
    do
        c.constructions.add(Current, id)
    end

    take_down(c: COLONY) is
    do
        c.constructions.remove(id)
    end

feature -- Configuration

    set_farming(proportional, fixed: INTEGER) is
    require
        proportional >= 0
        fixed >= 0
    do
        farming_proportional := proportional
        farming_fixed := fixed
    ensure
        farming_proportional = proportional
        farming_fixed = fixed
    end


    set_industry(proportional, fixed: INTEGER) is
    require
        proportional >= 0
        fixed >= 0
    do
        industry_proportional := proportional
        industry_fixed := fixed
    ensure
        industry_proportional = proportional
        industry_fixed = fixed
    end


    set_science(proportional, fixed: INTEGER) is
    require
        proportional >= 0
        fixed >= 0
    do
        science_proportional := proportional
        science_fixed := fixed
    ensure
        science_proportional = proportional
        science_fixed = fixed
    end

    set_cost(newcost: INTEGER) is
    do
        base_cost := newcost
    ensure
        base_cost = newcost
    end

    set_maintenance(newmaintenance: INTEGER) is
    do
        base_maintenance := newmaintenance
    ensure
        base_maintenance = newmaintenance
    end

feature {NONE} -- Creation

    make(newname: STRING; newid: INTEGER) is
    do
        name := newname
        id := newid
    end

feature {NONE} -- Implementation

    base_maintenance, base_cost: INTEGER

    farming_proportional, farming_fixed,
    industry_proportional, industry_fixed,
    science_proportional, science_fixed: INTEGER

end -- BASIC_PRODUCTIVE_CONSTRUCTION
