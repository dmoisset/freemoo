class BUILDABLE_CONSTRUCTION
-- Makes a construction buildable, buyable, and maintainable

inherit
    CONSTRUCTION
    redefine name end

create
    make

feature -- Access

    name: STRING

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

    make(new_name: STRING; new_id: INTEGER) is
    do
        id := new_id
        name := new_name
    end

feature {NONE} -- Implementation

    base_cost, base_maintenance: INTEGER

end -- class BUILDABLE_CONSTRUCTION
