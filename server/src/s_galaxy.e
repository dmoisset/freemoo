class S_GALAXY

inherit
    GALAXY
        redefine stars, set_stars end
    SERVICE
        redefine subscription_message end

feature -- Redefined features
    subscription_message (service_id: STRING):STRING is
        -- `service_id' can be "galaxy" for getting public information
        -- about whereabouts of stars, or "<n>:scanner", where <n> is
        -- the `color_id' of a player, to get scaner information for
        -- that player.
    require
        service_id /= Void
    local
        s: SERIALIZER
        id: INTEGER
        reading: ARRAY[FLEET]
        fleet: ITERATOR[FLEET]
        ship: ITERATOR[SHIP]
    do
-- If first subscription to `service_id', add to `ids'
        ids.add(service_id)

        if service_id = "galaxy" then
-- Public "galaxy" service
            !!Result.make (0)
            s.serialize ("i", <<stars.count>>)
            Result.append (s.serialized_form)
            from
                id := 0
            until
                id >= stars.count
            loop
                s.serialize ("iii", <<id, (stars @ id).kind - (stars @ id).kind_min,
                                      (stars @ id).size - (stars @ id).stsize_min>>)
                Result.append (s.serialized_form)
                Result.append (stars.item(id).serial_form)
                id := id + 1
            end
        elseif (service_id.count = 9) and then service_id.has_suffix(":scanner") and then service_id.item(1).is_digit then
-- Per player "n:scanner" service
            id := (service_id @ 1).to_integer
            reading := scanner(id)
            !!Result.make (0)
            s.serialize ("i", <<reading.count>>)
            from
                fleet := reading.get_new_iterator
            until fleet.is_off loop
                s.serialize("iiii", <<fleet.item.owner, fleet.item.eta,
                                 fleet.item.destination, fleet.item.ship_count>>)
                Result.append (s.serialized_form)
                Result.append (fleet.item.serial_form)
                from ship := fleet.item.get_new_iterator
                until ship.is_off loop
                    s.serialize("ii", <<ship.item.size, ship.item.picture>>)
                    -- Not sure if picture should be unique value or number...
                    Result.append (s.serialized_form)
                    ship.next
                end
                fleet.next
            end
        end
    end

feature {MAP_GENERATOR} -- Generation
    set_stars (starlist: ARRAY[S_STAR]) is
    do
        Precursor(starlist)
        update_clients
    end


feature -- Access
    stars: ARRAY[S_STAR]

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
