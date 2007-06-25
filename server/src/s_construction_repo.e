class S_CONSTRUCTION_REPO

inherit
    SERVICE
        redefine subscription_message end
    CONSTRUCTION_REPO
    redefine builder, starship_type, add_by_id, add_starship_design end

creation
    make

feature {NONE} -- Redefined features

    builder: S_CONSTRUCTION_BUILDER

    starship_type: S_STARSHIP

feature

    add_by_id(id: INTEGER) is
    do
        Precursor (id)
        update_clients
    end

    add_starship_design(design: like starship_type) is
    do
        Precursor (design)
        update_clients
    end

    update_clients is
    do
        -- Check to avoid updates on initialization
        if registry /= Void and then service_id /= Void then
            print ("In S_CONSTRUCTION_REPO.update_clients: sending message!%N")
            send_message (service_id, subscription_message (service_id))
        end
    end

    subscription_message (sid: STRING): STRING is
    local
        s: SERIALIZER2
        const_it: ITERATOR[CONSTRUCTION]
        starship: S_SHIP_CONSTRUCTION
    do
        if sid.has_suffix ("constructions") then
            if service_id = Void then
                service_id := sid
            end
            create s.make
            s.add_integer (count)
            const_it := get_new_iterator
            from const_it.start until const_it.is_off loop
                s.add_integer(const_it.item.id - product_min)
                if const_it.item.id > product_max then
                    starship ?= const_it.item
                    check starship /= Void end
                    starship.design.serialize_completely_on(s)
                end
                const_it.next
            end
            Result := s.serialized_form
        end
    end

feature {NONE} -- Implementation

    service_id: STRING

end -- class S_CONSTRUCTION_REPO
