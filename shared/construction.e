deferred class CONSTRUCTION
-- Basic construction for putting on colonies

feature -- Access

    name: STRING is
        -- Canonical name of the construction
    deferred
    end

    can_be_built_on(c: COLONY): BOOLEAN is
    deferred
    end

    cost(c: COLONY): INTEGER is
        -- Industry needed to build this construction at `c'
    deferred
    end

    maintenance: INTEGER is
        -- Maintenance cost per turn
    deferred
    end

feature -- Operations

    produce_proportional(c: COLONY) is
        -- Increase production on `c' proportionally to `c''s population
    deferred
    end

    produce_fixed(c: COLONY) is
        -- Increase production on `c' by a fixed amount
    deferred
    end

    clean_up_pollution(c: COLONY) is
        -- Reduce pollution penalty on colony `c'
    deferred
    end

    build(c: COLONY) is
        -- Do whatever this construction does when it is built
    deferred
    end

    take_down(c: COLONY) is
        -- Undo whatever this construction did when built
    deferred
    end

end
