class S_COLONY_SHIP

inherit
    S_SHIP
        redefine
            creator, get_class, make_from_storage, fields_array,
            dependents, subscription_message, serialize_on, owner
        end
    S_COLONIZER
        redefine
            owner, planet_to_colonize, set_planet_to_colonize, colonize
        end
    COLONY_SHIP
        undefine
            set_picture
        redefine
            creator, planet_to_colonize, set_planet_to_colonize, owner,
            colonize
        end
    SERVER_ACCESS

creation
    make

feature

    owner: like creator

    creator: S_PLAYER

feature

    subscription_message (service_id: STRING): STRING is
    local
        s: SERIALIZER2
    do
        create s.make
        if planet_to_colonize /= Void then
            s.add_tuple(<<planet_to_colonize.orbit_center.id.box,
                planet_to_colonize.orbit.box>>)
        else
            s.add_tuple(<<(-1).box, (0).box>>)
        end
        Result := s.serialized_form
    end

feature -- Redefined features

    planet_to_colonize: S_PLANET

    colonize is
    do
        Precursor{COLONY_SHIP}
    end

    set_planet_to_colonize(p: like planet_to_colonize) is
    do
        Precursor{COLONY_SHIP}(p)
        update_clients
    end

    serialize_on (s: SERIALIZER2) is
    do
        s.add_tuple(<<creator.id.box>>)
    end

feature -- Saving

    get_class: STRING is "COLONY_SHIP"

    fields_array: ARRAY[TUPLE[STRING, ANY]] is
    do
        Result := Precursor
        Result.add_last(["planet_to_colonize", planet_to_colonize])
    end

    dependents: ITERATOR[STORABLE] is
    do
        Result := (<<creator, owner, planet_to_colonize>>).get_new_iterator
    end

    make_from_storage (elems: ITERATOR [TUPLE [STRING, ANY]]) is
    do
        from
        until elems.is_off loop
            Precursor(elems)
            if not elems.is_off then
                if elems.item.first.is_equal("planet_to_colonize") then
                    planet_to_colonize ?= elems.item.second
                end
            end
            elems.next
        end
    end

end -- class S_COLONY_SHIP
