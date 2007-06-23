class TECH_FIELD
--
-- A group of technologies
--

inherit
    TECHNOLOGY_CONSTANTS

creation
    make

feature

    id: INTEGER

    cost: INTEGER

    name: STRING

    is_general: BOOLEAN

    category: TECH_CATEGORY

    get_new_iterator: ITERATOR[like tech] is
    do
        Result := techs.get_new_iterator_on_items
    end

    has(tech_id: INTEGER): BOOLEAN is
    do
        Result := techs.has(tech_id)
    end

    tech(tech_id: INTEGER): TECHNOLOGY is
    require
        has(tech_id)
    do
        Result := techs.at(tech_id)
    ensure
        Result.field = Current
    end

feature -- Operations

    set_cost(new_cost: INTEGER) is
    do
        cost := new_cost
    end

    set_name(new_name: STRING) is
    do
        name := new_name
    end

    set_is_general(new_is_general: BOOLEAN) is
    do
        is_general := new_is_general
    end

feature {NONE} -- Representation

    techs: HASHED_DICTIONARY[like tech, INTEGER]

feature {TECH_CATEGORY} -- Operations

    set_category (new_category: like category) is
    do
        category := new_category
    ensure
        category = new_category
    end

feature {TECHNOLOGY_TREE} -- Operations

    add_tech(t: like tech) is
    require
        t /= Void
        not has(t.id)
    do
        t.set_field (Current)
        techs.add(t, t.id)
    end

    remove_tech(tech_id: INTEGER) is
    require
        has(tech_id)
    do
        techs.remove(tech_id)
    end

feature {NONE} -- Creation

    make (new_id: INTEGER) is
    require
        is_valid_field_id (new_id)
    do
        id := new_id
        create techs.make
    end

end -- class TECH_FIELD
