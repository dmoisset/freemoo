class S_FLEET

inherit
    SERVICE
        redefine subscription_message end
    FLEET
        redefine set_destination, add_ship end

creation make

feature -- Redefined features
    set_destination (dest: STAR) is
    do
        Precursor (dest)
        if registry /= Void then
            update_clients
        end
    end

    subscription_message (service_id: STRING): STRING is
        -- Complete information of fleet, with info about ships and
        -- everything
    local
        s: SERIALIZER2
        i: ITERATOR[SHIP]
    do
        -- Currently just has same info as scanner
        s.add_tuple(<< owner, eta >>)
        if eta = 0 then
            s.add_integer(orbit_center.id)
        else
            s.add_integer(destination.id)
        end
        s.add_integer(ship_count)
        serialize_on(s)
        from i := ships.get_new_iterator
        until i.is_off
        loop
            s.add_tuple(<<i.item.size, i.item.picture>>)
	    i.next
        end
        Result := s.serialized_form
    end

    update_clients is
    do
        send_message("fleet" + id.to_string, subscription_message("fleet" + id.to_string))
    end

    add_ship(sh: SHIP) is
    do
        Precursor(sh)
        if registry /= Void then
            update_clients
        end
    end

end -- class S_FLEET