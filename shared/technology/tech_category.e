class TECH_CATEGORY
--
-- An group of tech_fields, in incrementing degree of difficulty
--

inherit
    TECHNOLOGY_CONSTANTS

creation
    make

feature

    id: INTEGER

    name: STRING

    get_new_iterator: ITERATOR[like field] is
    do
        Result := field_order.get_new_iterator
    end

    has_field (field_id: INTEGER): BOOLEAN is
    do
        Result := fields.has(field_id)
    end

    has_tech (tech_id: INTEGER): BOOLEAN is
    local
        it: ITERATOR [like field]
    do
        from
            it := field_order.get_new_iterator
        until
            Result or it.is_off
        loop
            Result := it.item.has (tech_id)
            it.next
        end
    end

    field (field_id: INTEGER): TECH_FIELD is
    require
        has_field (field_id)
    do
        Result := fields.at(field_id)
    ensure
        Result.category = Current
    end

    count: INTEGER is
    do
        Result := field_order.count
    end

    field_by_order (order: INTEGER): like field is
    require
        order.in_range (1, count)
    do
        Result := field_order.item (order)
    end

    field_after (t: TECHNOLOGY): like field is
        -- Returns the field that comes after a certain tech id
        -- (to know what field you should research after researching a tech)
    require
        has_tech (t.id)
    do
        Result := field_by_order (field_order.fast_index_of (t.field) + 1)
    ensure
        has_field (Result.id)
    end

    tech (tech_id: INTEGER): TECHNOLOGY is
    require
        has_tech (tech_id)
    local
        it: ITERATOR [like field]
    do
        from
            it := field_order.get_new_iterator
        until
            it.item.has (tech_id)
        loop
            it.next
        end
        Result := it.item.tech (tech_id)
    end

feature {NONE} -- Representation

    fields: HASHED_DICTIONARY[like field, INTEGER]

    field_order: ARRAY[like field]

feature {TECHNOLOGY_TREE}

    set_name (new_name: STRING) is
    require
        new_name /= Void
    do
        name := new_name
    ensure
        name = new_name
    end

    add_field(f: like field) is
        -- Add a field to this category.  The iterator shall retrieve fields in
        -- the same order they were added
    require
        f /= Void
        not has_field(f.id)
    do
        f.set_category (Current)
        fields.add(f, f.id)
        field_order.add_last (f)
    ensure
        has_field (f.id)
    end

    remove_field(field_id: INTEGER) is
    require
        has_field(field_id)
    do
        field_order.remove (field_order.index_of (fields.at (field_id)))
        fields.remove(field_id)
    ensure
        not has_field(field_id)
    end

feature {NONE} -- Creation

    make (new_id: INTEGER) is
    require
        new_id.in_range (category_construction, category_force_fields)
    do
        id := new_id
        create fields.make
        create field_order.make (1, 0)
    end

invariant

    fields.count = field_order.count

end -- class TECH_CATEGORY
