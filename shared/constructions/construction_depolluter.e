class CONSTRUCTION_DEPOLLUTER

inherit
    REPLACEABLE_CONSTRUCTION
    redefine
        cost, clean_up_pollution
    end
    GETTEXT

creation
    make

feature

    cost(c: like colony_type): INTEGER is
        -- There's some replacement between pollution eliminators,
        -- but they don't cost less for replacing others
    do
        Result := base_cost
    end

    clean_up_pollution(c: like colony_type) is
        -- We know that
        --      P = I/2 - x
        -- where P is the Pollution, I is total production and x is
        -- a value that depends on the planet's size.  We also have
        --      P2 = I/2 * p - x
        -- Where P2 is the Pollution after cleansing, and p is our
        -- cleansing power (0.5 for a pollution processor, for example).
        -- So, operating, we obtain
        --      P2 = (P + x)*(p - 1) + P
    local
        pollution: REAL
        x: INTEGER
        cleaned: REAL
    do
        x := c.location.size - c.location.plsize_min + 1
        pollution := -(c.industry.get_amount_due_to(l("Pollution Penalty")))
        cleaned := ((pollution + x) * (1 - cleansing_power)).min(pollution)
        c.industry.add(cleaned, l("Pollution Penalty"))
    end

feature -- Operations

    set_cleansing_power(p: REAL) is
        -- Production is reduced by a factor of `p' before
        -- calculating pollution
    do
        cleansing_power := p
    ensure
        cleansing_power = p
    end

feature {NONE} -- Implementation

    cleansing_power: REAL

invariant

    cleansing_power.in_range(0, 1)

end -- class CONSTRUCTION_DEPOLLUTER
