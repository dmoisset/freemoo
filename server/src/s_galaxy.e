class S_GALAXY

inherit
    GALAXY
        redefine stars, set_stars, make, create_star end
    SERVICE
        redefine subscription_message end

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
        ship: ITERATOR [SHIP]
    do
-- If first subscription to `service_id', add to `ids'
        ids.add(service_id)

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
                if fleet.item.destination /= Void then
                    s.serialize("iiii", <<fleet.item.owner.id, fleet.item.eta,
                                        fleet.item.destination.id,
                                        fleet.item.ship_count>>)
                else
                    s.serialize("iiii", <<fleet.item.owner.id, fleet.item.eta,
                                        fleet.item.orbit_center.id,
                                        fleet.item.ship_count>>)
                end
                Result.append (s.serialized_form)
                Result.append (fleet.item.serial_form)
                from ship := fleet.item.get_new_iterator
                until ship.is_off loop
                    s.serialize("ii", <<ship.item.size, ship.item.picture>>)
                    Result.append (s.serialized_form)
                    ship.next
                end
                fleet.next
            end
        else
            check unexpected_service_id: False end
        end
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
