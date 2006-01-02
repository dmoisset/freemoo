class BASIC_PRODUCTIVE_CONSTRUCTION
--
-- This is a basic construction that produces food, industry and/or
-- research on a colony on a fixed or per-populator basis.
-- You can build one if you don't already have one.
--

inherit
    CONSTRUCTION
    redefine
        name
    end
    GETTEXT

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

    generate_money(c: like colony_type) is
    do
        c.money.add(((c.money.total - c.money.get_amount_due_to(l("Maintenance")))
                     * money_percentage) / 100, name)
    end

    produce_proportional(c: like colony_type) is
    do
        c.farming.add(farming_proportional * (c.census @ task_farming), name)
        c.industry.add(industry_proportional * (c.census @ task_industry), name)
        c.science.add(science_proportional * (c.census @ task_science), name)
    end

    produce_fixed(c: like colony_type) is
    do
        c.farming.add(farming_fixed, name)
        c.industry.add(industry_fixed, name)
        c.science.add(science_fixed, name)
    end

    clean_up_pollution(c: like colony_type) is
    do
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
        -- Set farming generation values
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
        -- Set industry generation values
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
        -- Set science generation values
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

    set_money(new_money: INTEGER) is
        -- Set money generation factor to `new_money'
    do
        money_percentage := new_money
    ensure
        money_percentage = new_money
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
    money_percentage: INTEGER

end -- BASIC_PRODUCTIVE_CONSTRUCTION
