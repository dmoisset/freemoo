class S_GALAXY

inherit
    GALAXY
        redefine stars, set_stars, make, create_star, create_fleet, add_fleet end
    SERVICE
        redefine subscription_message end
    SERVER
        rename make as server_make end

creation make

feature {NONE} -- Creation

    make is
    do
        Precursor
        !!ids.make
    end

feature -- Redefined features

    subscription_message (service_id: STRING):STRING is
        -- `service_id' can be "galaxy" for getting public information
        -- about whereabouts of stars, or "<n>:scanner", where <n> is
        -- the `id' of a player, to get scaner information for
        -- that player.
    require
        service_id /= Void
    local
        s: SERIALIZER
        id: INTEGER
        star: ITERATOR [S_STAR]
        reading: ARRAY [FLEET]
        fleet: ITERATOR [FLEET]
    do
-- If first subscription to `service_id', add to `ids'
        if not service_id.has_suffix(":new_fleets") then
            ids.add(service_id)
        end
        if service_id.is_equal("galaxy") then
-- Public "galaxy" service
            !!Result.make (0)
            Result.append (limit.serial_form)
            s.serialize ("i", <<stars.count>>)
            Result.append (s.serialized_form)
            from
                star := stars.get_new_iterator_on_items
            until
                star.is_off
            loop
                s.serialize ("iii", <<star.item.id, star.item.kind - star.item.kind_min,
                                      star.item.size - star.item.stsize_min>>)
                Result.append (s.serialized_form)
                Result.append (star.item.serial_form)
                star.next
            end
        elseif service_id.has_suffix(":scanner") and then
                service_id.substring(1, service_id.count - 8).is_integer then
-- Per player "n:scanner" service
            id := service_id.substring(1, service_id.count - 8).to_integer
            reading := scans @ id
            s.serialize ("i", <<reading.count>>)
            !!Result.copy (s.serialized_form)
            from
                fleet := reading.get_new_iterator
            until fleet.is_off loop
                Result.append (fleet.item.serialized_as_fleet)
                fleet.next
            end
        elseif service_id.has_suffix(":new_fleets") then
            !!Result.make(0)
            id := 0
            s.serialize("i", <<id>>)
            Result.append(s.serialized_form)
        else
            check unexpected_service_id: False end
        end
    end

    new_fleet_message(new_fleets: ARRAY[FLEET]): STRING is
    -- Message sent for the <n>+":new_fleets" service
    local
        s: SERIALIZER
        it: ITERATOR[FLEET]
    do
        !!s
        !!Result.make(0)
        s.serialize("i", <<new_fleets.count>>)
        Result.append(s.serialized_form)
        from
            it := new_fleets.get_new_iterator
        until
            it.is_off
        loop
            s.serialize("i", <<it.item.id>>)
            Result.append(s.serialized_form)
            it.next
        end
    end

    add_fleet(new_fleet: FLEET) is
    local
        s_new_fleet: S_FLEET
        farray: ARRAY[S_FLEET]
    do
        s_new_fleet ?= new_fleet
        check s_new_fleet /= Void end
        fleets.add(s_new_fleet, s_new_fleet.id)
        if s_new_fleet.orbit_center /= Void then
            s_new_fleet.orbit_center.fleets.add(s_new_fleet, s_new_fleet.id)
        end
        !!farray.make(0, 0)
        farray.put(s_new_fleet, 0)
        server.register(s_new_fleet, "fleet" + s_new_fleet.id.to_string)
        send_message(s_new_fleet.owner.id.to_string + ":new_fleets", new_fleet_message (farray))
    end

feature {MAP_GENERATOR} -- Generation

    set_stars (starlist: DICTIONARY[S_STAR, INTEGER]) is
    require starlist /= Void
    do
        stars := starlist
        update_clients
    ensure
        stars = starlist
    end

feature -- Redefined factory method

    create_star:S_STAR is
    do
        !!Result.make_defaults
    end

    create_fleet:S_FLEET is
    do
        !!Result.make
    end

feature -- Access

    stars: DICTIONARY[S_STAR, INTEGER]

    ids: SET[STRING]

feature -- Operations

    update_clients is
    local
        id: ITERATOR[STRING]
    do
        from id := ids.get_new_iterator
        until id.is_off loop
            send_message(id.item, subscription_message(id.item))
            id.next
        end
    end

end -- S_GALAXY
