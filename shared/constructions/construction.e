deferred class CONSTRUCTION
-- Basic construction.
-- A CONSTRUCTION is something that can be built on a colony.
-- Things in a colony's `constructions' list are also CONSTRUCTION,
-- but not necessarily all constructions that you build result in
-- something being added to your constructions list (for example,
-- building a spy doesn't add anything to your colony's constructions).

inherit
    PRODUCTION_CONSTANTS

feature -- Access

    id: INTEGER
        -- One of the product_* constants

    name: STRING is
        -- Canonical name of the construction
    do
    end

    can_be_built_on(c: like colony_type): BOOLEAN is
        -- Can this construction be built on `c'?
    require c /= Void
    do
    end

    cost(c: like colony_type): INTEGER is
        -- Industry needed to build this construction at `c'
    require c /= Void
    do
    end

    maintenance(c: like colony_type): INTEGER is
        -- Maintenance cost per turn
    require c /= Void
    do
    end

    description: STRING
        -- A descriptive string to tell people about this construction

feature -- Operations

    produce_proportional(c: like colony_type) is
        -- Increase production on `c' proportionally to `c''s population
    require c /= Void
    do
    end

    produce_fixed(c: like colony_type) is
        -- Increase production on `c' by a fixed amount
    require c /= Void
    do
    end

    clean_up_pollution(c: like colony_type) is
        -- Reduce pollution penalty on colony `c'
    require c /= Void
    do
    end

    build(c: like colony_type) is
        -- Do whatever this construction does when it is built
    require c /= Void
    do
    end

    take_down(c: like colony_type) is
        -- Undo whatever this construction did when built
    require c /= Void
    do
    end

    set_description(newdescription: STRING) is
        -- Set a new description for this building
    require
        newdescription /= Void
    do
        description := newdescription
    ensure
        description = newdescription
    end

feature {NONE} -- Anchors

    colony_type: COLONY

invariant
    name /= Void
    -- id.in_range(product_min, product_max) (not since ship_constructions...)
end
