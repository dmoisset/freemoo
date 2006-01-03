deferred class BUILDABLE_CONSTRUCTION
--
-- Makes a construction buildable, buyable, and maintainable
--

inherit
    CONSTRUCTION
    redefine cost, maintenance end

feature -- Access

    cost(c: like colony_type): INTEGER is
    do
        Result := base_cost
    end

    maintenance(c: like colony_type): INTEGER is
    do
        Result := base_maintenance
    end

feature -- Operations

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

feature {CONSTRUCTION} -- Implementation

    base_cost, base_maintenance: INTEGER

end -- class BUILDABLE_CONSTRUCTION
