class S_GALAXY
	
inherit
    GALAXY
	redefine make, last_star, last_fleet,
		add_fleet, generate_scans
	end
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
        fleet: ITERATOR [like last_fleet]
        ship: ITERATOR [SHIP]
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
                s.add_tuple (<<star.item.id,
                               star.item.kind - star.item.kind_min,
                               star.item.size - star.item.stsize_min>>)
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
                s.add_tuple (<<fleet.item.owner.id, fleet.item.eta>>)
                if fleet.item.is_stopped then
                    s.add_integer (fleet.item.orbit_center.id)
                else
                    s.add_integer (fleet.item.destination.id)
                end
                s.add_integer (fleet.item.ship_count)
                fleet.item.serialize_on (s)
                from ship := fleet.item.get_new_iterator until ship.is_off loop
                    s.add_tuple (<<ship.item.size, ship.item.picture>>)
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
        else
            check unexpected_service_id: False end
        end
        Result := s.serialized_form
    end

    build_fleet_message(new_fleets: like scanner; s: SERIALIZER2) is
        -- Serialize message sent for the ":new_fleets" in `s'
    local
        it: ITERATOR[FLEET]
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

    ids: SET[STRING]

feature -- Operations

	generate_scans (pl: ITERATOR [PLAYER]) is
	do
		Precursor (pl)
		update_clients
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

end -- S_GALAXY
