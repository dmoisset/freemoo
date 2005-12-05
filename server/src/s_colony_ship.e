class S_COLONY_SHIP
    
inherit
    S_SHIP
    redefine
        creator, make, get_class, make_from_storage, fields_array, 
        dependents, subscription_message, serialize_on
    end
    COLONY_SHIP
    undefine
        set_size, set_picture
    redefine creator, make, will_colonize, set_will_colonize, colonize end
    SERVER_ACCESS
    
creation make
        
feature

    creator: S_PLAYER

feature {NONE} -- Creation

    make(p: like creator) is
    do
        Precursor{S_SHIP}(p)
        set_colony_ship_attributes
    end

feature

    subscription_message (service_id: STRING): STRING is
    local
        s: SERIALIZER2
    do
        !!s.make
        s.add_tuple(<<is_stealthy.box, can_colonize.box>>)
        if will_colonize /= Void then
            s.add_tuple(<<will_colonize.orbit_center.id.box,
                will_colonize.orbit.box>>)
        else
            s.add_tuple(<<(-1).box, (0).box>>)
        end
        Result := s.serialized_form
    end

feature -- Redefined features

    will_colonize: S_PLANET

    set_will_colonize(p: like will_colonize) is
    do
        Precursor(p)
        update_clients
    end

    colonize is
    local
        c: S_COLONY
    do
        c := will_colonize.create_colony(owner)
        will_colonize := Void
        can_colonize := True
    end    

    serialize_on (s: SERIALIZER2) is
    do
        s.add_tuple(<<creator.id.box, can_colonize.box>>)
    end

feature -- Saving

    get_class: STRING is "COLONY_SHIP"

    fields_array: ARRAY[TUPLE[STRING, ANY]] is
    do
        Result := Precursor
        Result.add_last(["will_colonize", will_colonize])
        Result.add_last(["can_colonize", can_colonize.box])
    end

    dependents: ITERATOR[STORABLE] is
    do
        Result := (<<creator, owner, will_colonize>>).get_new_iterator
    end


    make_from_storage (elems: ITERATOR [TUPLE [STRING, ANY]]) is
    local
        b: REFERENCE [BOOLEAN]
    do
        from
        until elems.is_off loop
            Precursor(elems)
            if not elems.is_off then
                if elems.item.first.is_equal("will_colonize") then
                    will_colonize ?= elems.item.second
                end
                if elems.item.first.is_equal("can_colonize") then
                    b ?= elems.item.second
                    can_colonize := b.item
                end
            end
            elems.next
        end
    end

invariant
    can_colonize = (will_colonize = Void)
end -- class S_COLONY_SHIP
