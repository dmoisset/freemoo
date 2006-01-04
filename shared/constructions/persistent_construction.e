class PERSISTENT_CONSTRUCTION
--
-- These constructions persist in the colony sitting in the construction
-- list until they're taken down
--

inherit
    BUILDABLE_CONSTRUCTION
    redefine build, take_down, can_be_built_on end

create
    make

feature

    can_be_built_on(c: like colony_type): BOOLEAN is
    do
        Result := not c.constructions.has(id)
    end

    build(c: like colony_type) is
    do
        c.constructions.add(Current, id)
    end

    take_down(c: like colony_type) is
    do
        c.constructions.remove(id)
    end

end -- class PERSISTENT_CONSTRUCTION
