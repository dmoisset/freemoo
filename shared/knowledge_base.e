class KNOWLEDGE_BASE

inherit
    TECHNOLOGY_CONSTANTS
    TECHNOLOGY_TREE_ACCESS

creation
    make

feature -- Access

    knows (tech: TECHNOLOGY): BOOLEAN is
    do
        Result := known_technologies.fast_has (tech)
    end

    iterator_on_known_techs: ITERATOR[INTEGER] is
    do
        Result := known_technologies.get_new_iterator
    end

    next_field (cat: INTEGER): TECH_FIELD is
    require
        cat.in_range (category_construction, category_force_fields)
    do
        Result := next_fields @ cat
    end

    current_tech: TECHNOLOGY
        -- Technology being researched

feature -- Operations

    add_tech (new_tech: TECHNOLOGY) is
    require
        not has (new_tech)
    do
        known_technologies.add_last (new_tech)
    ensure
        has (new_tech)
    end

    set_current_research (new_tech: TECHNOLOGY) is
    do
        current_tech := new_tech
    ensure
        current_tech = new_tech
    end

    set_next_field (new_field: TECH_FIELD) is
    do
        next_fields.put (new_field, new_field.category)
    ensure
        next_field (new_field.category) = new_field
    end

feature {} -- Creation

    make is
    local
        cat: INTEGER
    do
        create next_fields.make (0, 7)
        from
            cat := category_construction
        until
            cat > category_force_fields
        loop
            next_fields.put (tech_tree.category (cat).field_by_order (1), cat)
            cat := cat + 1
        end
        create known_technologies.make (0, -1)
    end

feature {} -- Implementation

    next_fields: ARRAY[TECH_FIELD]

    known_technologies: ARRAY[TECHNOLOGY]

end
