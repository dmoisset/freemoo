class S_GALAXY

inherit
    GALAXY
    redefine make, last_star, last_fleet,
        add_fleet, generate_scans, generate_colony_knowledge, ship_type
    end
    SERVICE
    redefine subscription_message end
    STORABLE
    redefine dependents end
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

    subscription_message (service_id: STRING): STRING is
        -- `service_id' can be "galaxy" for getting public information
        -- about whereabouts of stars, or "<n>:scanner", where <n> is
        -- the `id' of a player, to get scaner information for
        -- that player.
    require
        service_id /= Void
    local
        s: SERIALIZER2
        id: INTEGER
        star: ITERATOR [like last_star]
        reading: like scanner
        colonies: HASHED_SET[COLONY]
        colony: ITERATOR[COLONY]
        fleet: ITERATOR [like last_fleet]
        ship: ITERATOR [like ship_type]
    do
        !!s.make
        -- If first subscription to `service_id', add to `ids'
        if not service_id.has_suffix(":new_fleets") then
            ids.add(service_id)
        end
        if service_id.is_equal("galaxy") then
        -- Public "galaxy" service
            limit.serialize_on (s)
            s.add_integer (stars.count)
            from
                star := stars.get_new_iterator_on_items
            until
                star.is_off
            loop
                s.add_tuple (<<star.item.id.box,
                               (star.item.kind - star.item.kind_min).box,
                               (star.item.size - star.item.stsize_min).box>>)
                star.item.serialize_on (s)
                star.next
            end
        elseif service_id.has_suffix(":scanner") and then
                service_id.substring(1, service_id.count - 8).is_integer then
            -- Per player "n:scanner" service
            id := service_id.substring(1, service_id.count - 8).to_integer
            reading := scans @ id
            s.add_integer (reading.count)
            from
                fleet := reading.get_new_iterator
            until fleet.is_off loop
                s.add_tuple (<<fleet.item.owner.id.box, fleet.item.eta.box>>)
                if fleet.item.is_stopped then
                    s.add_integer (fleet.item.orbit_center.id)
                else
                    s.add_integer (fleet.item.destination.id)
                end
                s.add_integer (fleet.item.ship_count)
                fleet.item.serialize_on (s)
                from ship := fleet.item.get_new_iterator until ship.is_off loop
                    s.add_integer (ship.item.ship_type - ship.item.ship_type_min)
                    ship.item.serialize_on(s)
                    ship.next
                end
                fleet.next
            end
        elseif service_id.has_suffix(":new_fleets") then
            !!reading.make (1, 0)
            id := service_id.substring(1, service_id.count - 11).to_integer
            from fleet := fleets.get_new_iterator_on_items until
                fleet.is_off
            loop
                if fleet.item.owner.id = id then
                    reading.add_last (fleet.item)
                end
                fleet.next
            end
            build_fleet_message (reading, s)
        elseif service_id.has_suffix(":enemy_colonies") and then
               service_id.substring(1, service_id.count - 15).is_integer then
            -- Per player "n:enemy_colonies" service
            id := service_id.substring(1, service_id.count - 15).to_integer
            colonies := enemy_colony_knowledge @ id
            s.add_integer (colonies.count)
            from
                colony := colonies.get_new_iterator
            until colony.is_off loop
                s.add_tuple (<<colony.item.location.orbit_center.id.box,
                               colony.item.location.orbit.box,
                               colony.item.owner.id.box>>)
                colony.next
            end
        else
            check unexpected_service_id: False end
        end
        Result := s.serialized_form
    end

    build_fleet_message(new_fleets: like scanner; s: SERIALIZER2) is
        -- Serialize message sent for the ":new_fleets" in `s'
    local
        it: ITERATOR[like last_fleet]
    do
        s.add_integer (new_fleets.count)
        from
            it := new_fleets.get_new_iterator
        until
            it.is_off
        loop
            s.add_integer (it.item.id)
            it.next
        end
    end

    add_fleet (new_fleet: like last_fleet) is
    local
        farray: ARRAY [like last_fleet]
        s: SERIALIZER2
    do
        Precursor (new_fleet)
        !!farray.make(0, 0)
        farray.put (new_fleet, 0)
        server.register (new_fleet, "fleet" + new_fleet.id.to_string)
        !!s.make; build_fleet_message (farray, s)
        send_message (new_fleet.owner.id.to_string + ":new_fleets", s.serialized_form)
    end

feature {MAP_GENERATOR} -- Generation

    last_star: S_STAR

    last_fleet: S_FLEET    

feature -- Access

    ids: HASHED_SET[STRING]

feature -- Operations

    generate_scans (pl: ITERATOR [PLAYER]) is
    local
        scanname: STRING
    do
        Precursor (pl)
-- This, is ugly, and similar but not exactly update_clients. It should
-- be cleaner
        from pl.start until pl.is_off loop
            scanname := pl.item.id.to_string+":scanner"
            if ids.has (scanname) then
                send_message(scanname, subscription_message(scanname))
            end
            pl.next
        end
    end
    
    generate_colony_knowledge (pl: ITERATOR [PLAYER]) is
    local
        service_name: STRING
    do
        Precursor (pl)
        -- same idea as generate_scans
        from pl.start until pl.is_off loop
            service_name := pl.item.id.to_string + ":enemy_colonies"
            if ids.has(service_name) then
                send_message(service_name, subscription_message(service_name))
            end
            pl.next
        end
    end

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
    
feature
    

feature -- Saving

    hash_code: INTEGER is
    do
        Result := Current.to_pointer.hash_code
    end

feature {STORAGE} -- Saving

    get_class: STRING is "GALAXY"
    
    fields: ITERATOR[TUPLE[STRING, ANY]] is
    local
        a: ARRAY[TUPLE[STRING, ANY]]
    do
        create a.make(1, 0)
        a.add_last(["limit", limit])
        add_to_fields(a, "stars", stars.get_new_iterator_on_items)
        add_to_fields(a, "fleets", fleets.get_new_iterator_on_items)
        Result := a.get_new_iterator
    end
    
    dependents: ITERATOR[STORABLE] is
    local
        a: ARRAY[STORABLE]
    do
        create a.make(1, 0)
        a.add_last(limit)
        add_dependents_to(a, stars.get_new_iterator_on_items)
        add_dependents_to(a, fleets.get_new_iterator_on_items)
        Result := a.get_new_iterator
    end

feature {STORAGE} -- Retrieving
    
    set_primary_keys (elems: ITERATOR [TUPLE [STRING, ANY]]) is
    do
    end
    
    make_from_storage (elems: ITERATOR [TUPLE [STRING, ANY]]) is
    local
        star: like last_star
        fleet: like last_fleet
    do
        from
            stars.clear
            fleets.clear
        until elems.is_off loop
            if elems.item.first.is_equal("limit") then
                limit ?= elems.item.second
            elseif elems.item.first.has_prefix("stars") then
                star ?= elems.item.second
                stars.add (star, star.id)
            elseif elems.item.first.has_prefix("fleets") then
                fleet ?= elems.item.second
                fleets.add(fleet, fleet.id)
                server.register (fleet, "fleet" + fleet.id.to_string)
            end
            elems.next
        end
    end
    
feature -- Anchors
    
    ship_type: S_SHIP
    
end -- S_GALAXY
