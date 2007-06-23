deferred class S_SHIP

inherit
    SHIP
        redefine creator, set_picture end
    STORABLE
        rename
            hash_code as id
        redefine
            dependents, primary_keys
        end
    SERVICE
        redefine subscription_message end

feature

    creator: S_PLAYER

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
    do
        create Result.make (0)
    end


feature {STORAGE} -- Saving

    fields_array: ARRAY[TUPLE[STRING, ANY]] is
        -- Array for `fields'
    do
        Result :=<<["creator", creator],
                   ["owner", owner],
                   ["picture", picture.box],
                   >>
    end

    primary_keys_array: ARRAY[TUPLE[STRING, ANY]] is
        -- Array for `primary_keys'
    do
        Result := <<["id", id.box]>>
    end

    fields: ITERATOR[TUPLE[STRING, ANY]] is
    do
        Result := fields_array.get_new_iterator
    end

    primary_keys: ITERATOR[TUPLE[STRING, ANY]] is
    do
        Result := primary_keys_array.get_new_iterator
    end


    dependents: ITERATOR[STORABLE] is
    do
        Result := (<<creator, owner>>).get_new_iterator
    end

feature {STORAGE} -- Retrieving


    set_primary_keys (elems: ITERATOR [TUPLE [STRING, ANY]]) is
    local
        i: REFERENCE [INTEGER]
        unknown_tag: BOOLEAN
    do
        from
        until elems.is_off or unknown_tag loop
            if elems.item.first.is_equal("id") then
                i ?= elems.item.second
                set_id(i.item)
            else
                unknown_tag := True
            end
            if not unknown_tag then
                elems.next
            end
        end
    end

    make_from_storage (elems: ITERATOR [TUPLE [STRING, ANY]]) is
    local
        i: REFERENCE [INTEGER]
        unknown_tag: BOOLEAN
    do
        from
        until elems.is_off or unknown_tag loop
            if elems.item.first.is_equal("creator") then
                creator ?= elems.item.second
            elseif elems.item.first.is_equal("owner") then
                owner ?= elems.item.second
            elseif elems.item.first.is_equal("picture") then
                i ?= elems.item.second
                picture := i.item
            else
                unknown_tag := True
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
