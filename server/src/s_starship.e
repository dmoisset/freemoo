class S_STARSHIP
    
inherit
    S_SHIP
    redefine
        creator, fields_array, make_from_storage, serialize_on,
        subscription_message, make, get_class
    end
    STARSHIP
    undefine
        set_size, set_picture
    redefine creator, make end
    
creation make
    
feature
    creator: S_PLAYER

feature

    serialize_on(s: SERIALIZER2) is
    do
        Precursor(s)
        s.add_tuple(<<size.box, picture.box>>)
    end

    subscription_message (service_id: STRING): STRING is
    local
        s: SERIALIZER2
    do
        !!s.make
        s.add_tuple(<<name, fuel_range.box, is_stealthy.box>>)
        Result := s.serialized_form
    end

feature

    get_class: STRING is "STARSHIP"

    fields_array: ARRAY[TUPLE[STRING, ANY]] is
    do
        Result := Precursor
        Result.add_last(["name", name])
    end
    
    make_from_storage (elems: ITERATOR [TUPLE [STRING, ANY]]) is
    do
        from
        until elems.is_off loop
            Precursor(elems)
            if not elems.is_off then
                if elems.item.first.is_equal("name") then
                    name ?= elems.item.second
                end
            end
            elems.next
        end
    end

feature {NONE} -- Creation

    make (p: like creator) is
    do
        Precursor{S_SHIP}(p)
        set_starship_attributes
    end

end -- class S_STARSHIP
