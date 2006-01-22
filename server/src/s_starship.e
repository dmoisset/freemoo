class S_STARSHIP

inherit
    S_SHIP
    redefine
        creator, primary_keys_array, set_primary_keys, make_from_storage,
        serialize_on, subscription_message, get_class
    end
    STARSHIP
    undefine
        set_size, set_picture, make
    redefine creator end

creation
    make, from_design

feature -- Access

    creator: S_PLAYER

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
        s.add_tuple(<<name, fuel_range.box>>)
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

    set_primary_keys (elems: ITERATOR [TUPLE [STRING, ANY]]) is
    do
        from
        until elems.is_off loop
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
    do
        from
        until elems.is_off loop
            Precursor(elems)
            if not elems.is_off then
                print ("Unknown field '" + elems.item.first + "' in STARSHIP element%N")
                elems.next
            end
        end
    end

end -- class S_STARSHIP
