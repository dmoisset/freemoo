class S_SHIP

inherit
    SHIP
    redefine creator, set_size, set_picture end
    STORABLE
    rename
        hash_code as id
    redefine
        dependents, primary_keys
    end
    SERVICE
    redefine subscription_message end

creation make

feature

    creator: S_PLAYER

    set_size (s: INTEGER) is
    do
        Precursor(s)
        update_clients
    end

    set_picture(p: INTEGER) is
    do
        Precursor(p)
        update_clients
    end

feature -- Operations

    update_clients is
    do
        -- Check to avoid updates on initialization
        if registry /= Void then
            send_message ("ship" + id.to_string, subscription_message ("ship" + id.to_string))
        end
    end

    subscription_message (service_id: STRING): STRING is
    require
        service_id.is_equal("ship" + id.to_string)
    local
        s: SERIALIZER2
    do
        !!s.make
        s.add_boolean(is_stealthy)
        Result := s.serialized_form
    end


feature {STORAGE} -- Saving

    fields_array: ARRAY[TUPLE[STRING, ANY]] is
        -- Array for `fields'
    do
        Result :=<<["creator", creator],
                   ["owner", owner],
                   ["size", size.box],
                   ["picture", picture.box],
                   ["is_stealthy", is_stealthy.box]
                   >>
    end

    fields: ITERATOR[TUPLE[STRING, ANY]] is
    do
        Result := fields_array.get_new_iterator
    end

    primary_keys: ITERATOR[TUPLE[STRING, ANY]] is
    do
        Result := (<<["id", id.box] >>).get_new_iterator
    end


    dependents: ITERATOR[STORABLE] is
    do
        Result := (<<creator, owner>>).get_new_iterator
    end

feature {STORAGE} -- Retrieving


    set_primary_keys (elems: ITERATOR [TUPLE [STRING, ANY]]) is
    local
        i: REFERENCE [INTEGER]
    do
        from
        until elems.is_off loop
            if elems.item.first.is_equal("id") then
                i ?= elems.item.second
                set_id(i.item)
            end
            elems.next
        end
    end

    make_from_storage (elems: ITERATOR [TUPLE [STRING, ANY]]) is
    local
        b: REFERENCE [BOOLEAN]
        i: REFERENCE [INTEGER]
        unknown_tag: BOOLEAN
    do
        from
        until elems.is_off or unknown_tag loop
            if elems.item.first.is_equal("creator") then
                creator ?= elems.item.second
            elseif elems.item.first.is_equal("owner") then
                owner ?= elems.item.second
            elseif elems.item.first.is_equal("size") then
                i ?= elems.item.second
                size := i.item
            elseif elems.item.first.is_equal("picture") then
                i ?= elems.item.second
                picture := i.item
            elseif elems.item.first.is_equal("is_stealthy") then
                b ?= elems.item.second
                is_stealthy := b.item
            else
                unknown_tag := true
            end
            if not unknown_tag then
                elems.next
            end
        end
    end

feature

    serialize_on (s: SERIALIZER2) is
    do
        s.add_integer(creator.id)
    end

end -- class S_SHIP
