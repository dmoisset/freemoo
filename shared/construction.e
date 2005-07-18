deferred class CONSTRUCTION
-- Basic construction for putting on colonies

feature -- Access

    name: STRING is
        -- Canonical name of the construction
    deferred
    end

    can_be_built_on(c: COLONY): BOOLEAN is
        -- Can this construction be built on `c'?
    require c /= Void
    deferred
    end

    cost(c: COLONY): INTEGER is
        -- Industry needed to build this construction at `c'
    require c /= Void
    deferred
    end

    maintenance: INTEGER is
        -- Maintenance cost per turn
    deferred
    end

feature -- Operations

    produce_proportional(c: COLONY) is
        -- Increase production on `c' proportionally to `c''s population
    require c /= Void
    deferred
    end

    produce_fixed(c: COLONY) is
        -- Increase production on `c' by a fixed amount
    require c /= Void
    deferred
    end

    clean_up_pollution(c: COLONY) is
        -- Reduce pollution penalty on colony `c'
    require c /= Void
    deferred
    end

    build(c: COLONY) is
        -- Do whatever this construction does when it is built
    require c /= Void
    deferred
    end

    take_down(c: COLONY) is
        -- Undo whatever this construction did when built
    require c /= Void
    deferred
    end

invariant
    name /= Void
end
