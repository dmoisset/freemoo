class TECH_KNOWLEDGE
--
-- A player's main technology repository.
--

feature -- Known technologies

    has(id: INTEGER): BOOLEAN is
    do
        Result := known_techs.has(id)
    end

    item, infix "@" (id: INTEGER): TECHNOLOGY is
    require
        has(id)
    do
        Result := known_techs.at(id)
    end

    add(id: INTEGER) is
    require
        not has(id)
    do
        known_techs.add(id)
    end

feature {NONE} -- Representation

    known_techs: HASHED_SET[INTEGER]
    -- Technologies we've acquired 

    tree: TECHNOLOGY_TREE
    -- Our complete technology tree

    researching: TECHNOLOGY
    -- Technology currently being researched

    research_level: ARRAY[INTEGER]
    -- Next field index we can research for each category

invariant
    research_level.lower = category_min
    research_level.upper = category_max
end -- TECH_KNOWLEDGE
