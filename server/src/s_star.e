class S_STAR

inherit
    UNIQUE_ID
    STAR
        redefine
            set_planet, set_special, set_name
        end
    SERVICE
        redefine subscription_message

feature -- Redefined Features
    subscription_message (service_id: STRING): STRING is
    local
        s: SERIALIZER
        i: ITERATOR [PLANET]
    do
    -- Setup id upon first subscription
        if s_id = Void then
            s_id := service_id
        end
        !!Result.make (0)
        s.serialize ("si", <<name, planets.count>>)
        Result.append (s.serialized_form)
        from
            i := planets.get_new_iterator
        until i.is_off loop
            s.serialize ("iiiiii", <<i.item.size - i.item.plsize_min, i.item.climate - i.item.climate_min,
                                     i.item.mineral - i.item.mnrl_min, i.item.gravity - i.item.grav_min,
                                     i.item.special - i.item.plspecial_min, i.item.orbit>>)
            Result.append (s.serialized_form)
            i.next
        end
    end

feature {MAP_GENERATOR} -- Redefined
    set_planet (newplanet: PLANET; orbit: INTEGER) is
    do
        Precursor(newplanet, orbit)
        update_clients
    end

    set_special (new_special: INTEGER) is
    do
        Precursor(new_special)
        update_clients
    end

    set_name (new_name: STRING) is
    do
        Precursor(new_name)
        update_clients
    end

feature -- Access

    s_id: STRING
        -- Name of the service we provide


feature -- Operations

    update_clients is
    do
        send_message (s_id, subscription_message (s_id))
    end


end -- class S_STAR
