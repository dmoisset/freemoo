class S_FLEET

inherit
    SERVICE
        redefine subscription_message end
    FLEET
        redefine
            set_destination, add_ship, split, move,
            splitted_fleet, join, clear_ships, orbit_center
        end

creation make

feature -- Redefined features

    splitted_fleet: S_FLEET

    orbit_center: S_STAR

    subscription_message (service_id: STRING): STRING is
        -- Complete information of fleet, with info about ships and
        -- everything
    local
        s: SERIALIZER2
        i: ITERATOR[SHIP]
    do
        !!s.make
        -- Currently just has same info as scanner
        s.add_tuple(<< owner, eta >>)
        if orbit_center/=Void then
            s.add_integer(orbit_center.id)
        else
            s.add_integer(-1)
        end
        if destination/=Void then
            s.add_integer(destination.id)
        else
            s.add_integer(-1)
        end
        s.add_integer(ship_count)
        serialize_on(s)
        from i := get_new_iterator until i.is_off loop
            s.add_tuple(<<i.item.id, i.item.size, i.item.picture>>)
            i.next
        end
        Result := s.serialized_form
    end

    set_destination (dest: like destination) is
    do
        Precursor (dest)
        update_clients
    end

    add_ship(sh: SHIP) is
    do
        Precursor(sh)
        update_clients
    end

    split (shs: SET [SHIP]) is
    do
        Precursor (shs)
        update_clients
    end
    
    join (other: FLEET) is
    do
        Precursor (other)
        update_clients
    end

    clear_ships is
    do
        Precursor
        update_clients
    end
    
    move is
    do
        Precursor
        update_clients
    end
    
feature {NONE} -- Internal

    update_clients is
    do
        if registry /= Void then
            send_message("fleet" + id.to_string, subscription_message("fleet" + id.to_string))
        end
    end

end -- class S_FLEET