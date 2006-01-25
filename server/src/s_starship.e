class S_STARSHIP

inherit
    S_SHIP
        undefine
            make
        redefine
            creator, primary_keys_array, fields_array,
            set_primary_keys, make_from_storage,
            serialize_on, subscription_message, get_class
        end
    STARSHIP
        undefine
            set_picture
        redefine
            creator, set_size
        end

creation
    make, from_design

feature -- Access

    creator: S_PLAYER

feature -- Operations

    set_size (s: INTEGER) is
    do
        Precursor(s)
        update_clients
    end

feature -- Serialization

    serialize_on(s: SERIALIZER2) is
    do
        Precursor(s)
        s.add_tuple(<<size.box, picture.box>>)
    end

    serialize_completely_on(s: SERIALIZER2) is
        -- Adds private information to the serialized, for SHIPn service
        -- Or transmitting starship blueprints.
    do
        s.add_string (name)
    end

    subscription_message (service_id: STRING): STRING is
    local
        s: SERIALIZER2
    do
        !!s.make
        serialize_completely_on(s)
        Result := s.serialized_form
    end

feature -- Storage

    get_class: STRING is "STARSHIP"

    primary_keys_array: ARRAY[TUPLE[STRING, ANY]] is
    do
        Result := Precursor
        Result.add_last(["name", name])
    end

    fields_array: ARRAY [TUPLE [STRING, ANY]] is
    do
        Result := Precursor
        Result.add_last (["size", size.box])
    end

    set_primary_keys (elems: ITERATOR [TUPLE [STRING, ANY]]) is
    do
        from until elems.is_off loop
            Precursor(elems)
            if not elems.is_off then
                if elems.item.first.is_equal("name") then
                    name ?= elems.item.second
                else
                    print("Unknown primary key '" + elems.item.first + "' in STARSHIP element%N")
                end
                elems.next
            end
        end
    end

    make_from_storage(elems: ITERATOR[TUPLE[STRING, ANY]]) is
    local
        i: REFERENCE [INTEGER]
    do
        from
        until elems.is_off loop
            Precursor(elems)
            if not elems.is_off then
                if elems.item.first.is_equal("size") then
                    i ?= elems.item.second
                    size := i.item
                else
                    print("Unknown field '" + elems.item.first + "' in STARSHIP element%N")
                end
                elems.next
            end
        end
    end

end -- class S_STARSHIP
