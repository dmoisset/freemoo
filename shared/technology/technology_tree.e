class TECHNOLOGY_TREE

inherit
    TECHNOLOGY_CONSTANTS
    PKG_USER

create
    make

feature -- Access

    category (cat: INTEGER): TECH_CATEGORY is
    require
        cat.in_range(category_construction, category_force_fields)
    do
        Result := categories @ cat
    end

    field (field_id: INTEGER): TECH_FIELD is
    require
        is_valid_field_id (field_id)
    local
        cat_id: INTEGER
    do
        from
            cat_id := category_construction
        until
            categories.item (cat_id).has_field (field_id)
        loop
            cat_id := cat_id + 1
        end
        Result := categories.item (cat_id).field (field_id)
    end

    tech (tech_id: INTEGER): TECHNOLOGY is
    require
        is_valid_tech_id (tech_id)
    local
        cat_id: INTEGER
    do
        from
            cat_id := category_construction
        until
            categories.item (cat_id).has_tech (tech_id)
        loop
            cat_id := cat_id + 1
        end
        Result := categories.item (cat_id).tech (tech_id)
    end

feature

    categories: ARRAY[like category]

feature {NONE} -- Creation

    make is
    local
        cat: INTEGER
        new_category: TECH_CATEGORY
    do
        create categories.make(category_construction, category_force_fields)
        from
            cat := category_construction
        until
            cat > category_force_fields
        loop
            create new_category.make (cat)
            categories.put (new_category, cat)
            cat := cat + 1
        end

        load_tech_tree
        -- TODO:  After reading in tech_descriptions, remember to add
        -- tech_advanced_governments to the field_advanced_government field, with appropiate
        -- government!
    end

    load_tech_tree is
        -- load technology costs and descriptions from file
    local
        f: COMMENTED_TEXT_FILE
        cat, fid, tid, p, q, cost: INTEGER
        name, description: STRING
        is_general: BOOLEAN
        a_field: TECH_FIELD
        a_tech: TECHNOLOGY
        tech_builder: TECHNOLOGY_BUILDER
    do
        create tech_builder
        pkg_system.open_file ("technology/tech_descriptions")
        create f.make (pkg_system.last_file_open)
        f.read_nonempty_line
        check well_formed: f.last_line.has_prefix ("***") end
        from
            cat := category_construction
        until
            cat > category_force_fields
        loop
            from
                fid := field_min @ cat
                f.read_nonempty_line
            until
                f.last_line = Void or else f.last_line.has_prefix ("***")
            loop
                check f.last_line.has_prefix ("*") end
                p := f.last_line.index_of ('|', 1)
                cost := f.last_line.substring (3, p - 1).to_integer
                q := f.last_line.index_of ('|', p + 1)
                is_general := f.last_line.substring (p + 1, q - 1).to_boolean
                name := f.last_line.substring (q + 1, f.last_line.count)

                create a_field.make (fid)
                a_field.set_name (name)
                a_field.set_cost (cost)
                a_field.set_is_general (is_general)

                from
                    f.read_nonempty_line
                until
                    f.last_line = Void or else f.last_line.has_prefix ("*")
                loop
                    p := f.last_line.index_of ('|', 1)
                    tid := f.last_line.substring (1, p - 1).to_integer + tech_min.item (category_construction)
                    q := f.last_line.index_of ('|', p + 1)
                    name := f.last_line.substring (p + 1, q - 1)
                    description := f.last_line.substring (q + 1, f.last_line.count)

                    tech_builder.by_id (tid)
                    a_tech := tech_builder.last_tech
                    a_tech.set_name (name)
                    a_tech.set_description (description)
                    a_field.add_tech (a_tech)

                    f.read_nonempty_line
                end
                categories.item (cat).add_field (a_field)
                fid := fid + 1
            end
            check fid = field_max.item(cat) + 1 end
            cat := cat + 1
        end
    end

invariant
    categories.lower = category_construction
    categories.upper = category_force_fields
end -- class TECHNOLOGY_TREE
