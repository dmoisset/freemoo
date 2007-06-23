class TECHNOLOGY_CONSTRUCTION
--
-- A TECHNOLOGY that allows you to build a new CONSTRUCTION
--

inherit
    TECHNOLOGY
        redefine research end

creation
    make

feature

    research(p: PLAYER) is
    do
        p.known_constructions.add_by_id (construction_id)
        Precursor (p)
    end

feature {NONE} -- Creation

    make(new_id: INTEGER; new_construction_id: INTEGER) is
    do
        id := new_id
        construction_id := new_construction_id
    ensure
        id = new_id
        construction_id = new_construction_id
    end

feature {NONE} -- Representation

    construction_id: INTEGER

end -- class TECHNOLOGY_CONSTRUCTION
