deferred class TECHNOLOGY

inherit
    TECHNOLOGY_CONSTANTS

feature

    id: INTEGER

    name: STRING

    description: STRING

    field: TECH_FIELD

    research(p: PLAYER) is
    require
        p /= Void
        not p.knowledge.knows(Current)
    do
        p.knowledge.add_tech(Current)
    ensure
        p.knowledge.knows(Current)
    end

feature {TECHNOLOGY_TREE} -- Setters

    set_name (new_name: STRING) is
    do
        name := new_name
    ensure
        name = new_name
    end

    set_description (new_description: STRING) is
    do
        description := new_description
    ensure
        description = new_description
    end

feature {TECH_FIELD}

    set_field (new_field: like field) is
    do
        field := new_field
    ensure
        field = new_field
    end

invariant

    is_valid_tech_id (id)

end -- class TECHNOLOGY
