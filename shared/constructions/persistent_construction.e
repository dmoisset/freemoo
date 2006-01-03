class PERSISTENT_CONSTRUCTION
--
-- These constructions persist in the colony sitting in the construction
-- list until they're taken down
--

inherit
    BUILDABLE_CONSTRUCTION
    redefine build, take_down end

create
    make

feature

    build(c: like colony_type) is
    do
        c.constructions.add(Current, id)
    end

    take_down(c: like colony_type) is
    do
        c.constructions.remove(id)
    end

end -- class PERSISTENT_CONSTRUCTION
