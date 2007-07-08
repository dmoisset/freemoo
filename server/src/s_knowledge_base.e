class S_KNOWLEDGE_BASE

inherit
    KNOWLEDGE_BASE
    redefine
        add_tech, set_current_tech, set_next_field
    end
    SERVICE
    redefine subscription_message end
    STORABLE
    redefine fields end

creation
    make

feature

    add_tech (new_tech: TECHNOLOGY) is
    do
        Precursor (new_tech)
        update_clients
    end

    set_current_tech (new_tech: TECHNOLOGY) is
    do
        Precursor (new_tech)
        update_clients
    end

    set_next_field (new_field: TECH_FIELD) is
    do
        Precursor (new_field)
        update_clients
    end

feature -- Service ID

    sid: STRING

feature

    update_clients is
    do
        -- Check to avoid updates on initialization
        if registry /= Void and then sid /= Void then
            send_message (sid, subscription_message (sid))
        end
    end

    subscription_message (service_id: STRING): STRING is
    local
        s: SERIALIZER2
        cat: INTEGER
        it: ITERATOR [TECHNOLOGY]
    do
        if sid = Void then
            -- Initialize service ID so we can know who to update later
            -- We're assuming the first service_id we receive is correct.
            -- ** Is this a security risk? **
            sid := service_id
        end
        create s.make
        if current_tech = Void then
            s.add_integer (-1)
        else
            s.add_integer (current_tech.id - tech_min.item (category_construction))
        end
        from
            cat := category_construction
        until
            cat > category_force_fields
        loop
            s.add_integer (next_field (cat).id - field_min.item (category_construction))
            cat := cat + 1
        end
        s.add_integer (known_technologies.count)
        from
            it := known_technologies.get_new_iterator
        until
            it.is_off
        loop
            s.add_integer (it.item.id - tech_min.item (category_construction))
            it.next
        end
        Result := s.serialized_form
    end

feature -- Storing

    get_class: STRING is "KNOWLEDGE_BASE"

    hash_code: INTEGER is
    do
        Result := to_pointer.hash_code
    end

    fields: ITERATOR[TUPLE[STRING, ANY]] is
    local
        a: ARRAY[TUPLE[STRING, ANY]]
        it: ITERATOR[TECHNOLOGY]
        index: INTEGER
    do
        create a.make (0, -1)
        from
            index := 1
            it := known_technologies.get_new_iterator
        until
            it.is_off
        loop
            a.add_last (["known" + index.to_string, (it.item.id - tech_min.item(category_construction)).box])
            index := index + 1
            it.next
        end
        from
            index := category_construction
        until
            index > category_force_fields
        loop
            a.add_last (["next_field" + index.to_string, (next_field (index).id - field_min.item (category_construction)).box])
            index := index + 1
        end
        index := -1
        if current_tech /= Void then
            index := current_tech.id - tech_min.item (category_construction)
        end
        a.add_last (["current_tech", index.box])
        Result := a.get_new_iterator
    end

    set_primary_keys (elems: ITERATOR [TUPLE [STRING, ANY]]) is
    do
    end

    make_from_storage (elems: ITERATOR [TUPLE [STRING, ANY]]) is
    local
        i: REFERENCE[INTEGER]
        new_field: TECH_FIELD
    do
        from
            known_technologies.clear
        until elems.is_off loop
            if elems.item.first.is_equal("current_tech") then
                i ?= elems.item.second
                if i.item >= 0 then
                    current_tech := tech_tree.tech (i.item + tech_min.item(category_construction))
                else
                    current_tech := Void
                end
            elseif elems.item.first.has_prefix("known") then
                i ?= elems.item.second
                known_technologies.add_last (tech_tree.tech (i.item + tech_min.item(category_construction)))
            elseif elems.item.first.has_prefix("next_field") then
                i ?= elems.item.second
                new_field := tech_tree.field (i.item + field_min.item(category_construction))
                next_fields.put (new_field, new_field.category.id)
            else
                print ("Bad element inside 'knowledge_base' tag: " + elems.item.first + "%N")
            end
            elems.next
        end
        update_clients
    end
end -- class S_KNOWLEDGE_BASE
