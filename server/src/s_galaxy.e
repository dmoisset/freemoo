class S_GALAXY

inherit
    PARSEC
    GALAXY
        redefine stars end
    SERVICE
        redefine subscription_message end

feature
    subscription_message(service_id: STRING):STRING is
        -- service_id can be `galaxy' for getting public information
        -- about whereabouts of stars, or `<n>scanner', where <n> is
        -- the color_id of a player, to get scaner information for
        -- that player.
    require
        service_id /= Void
    local
        s: SERIALIZER
        id: INTEGER
        ship: ITERATOR[SHIP]
        alienfleet, ownfleet: ITERATOR[FLEET]
        star: ITERATOR[STAR]
        planet: ITERATOR[PLANET]
        closest: INTEGER
        detected_ships, detected_fleets: INTEGER
        reported_ships, reported_fleets: STRING
    do
        if service_id = "galaxy" then
-- Public `galaxy' service
            !!Result.make (0)
            s.serialize ("i", <<stars.count>>)
            Result.append (s.serialized_form)
            from
                id := 0
            until
                id >= stars.count
            loop
                s.serialize ("iii", <<id, (stars @ id).kind, stars.item(id).size>>)
                Result.append (s.serialized_form)
                Result.append (stars.item(id).serial_form)
                id := id + 1
            end
        elseif service_id.has_suffix("scanner") and then service_id.item(1).is_digit then
-- Per player `nscanner' service
            id := (service_id @ 1).to_integer
            from
                alienfleet := fleets.get_new_iterator
                !!reported_fleets.make(0)
            until alienfleet.is_off loop
                if alienfleet.item.owner.color_id /= id then
            -- Find own closest asset, in parsecs.
            -- (Can be at negative distances, due to modifiers)
            -- (Currently doesn't consider any modifiers!)
                    from ownfleet:=fleets.get_new_iterator
                    until ownfleet.is_off loop
                        closest := closest.min(((ownfleet.item |-| alienfleet.item) / parsec).rounded)
                        ownfleet.next
                    end
                    from star := stars.get_new_iterator
                    until star.is_off loop
                        from planet := star.item.planets.get_new_iterator
                        until planet.is_off loop
                            if planet.item.colony /= Void and then planet.item.colony.owner.color_id = id then
                                closest := closest.min(((planet.item.orbit_center |-| alienfleet.item) / parsec).rounded)
                            end
                            planet.next
                        end
                        star.next
                    end
            -- Determine which ships in alien fleet are detected, and report them
                    from
                        ship:=alienfleet.item.get_new_iterator
                        detected_ships := 0
                        !!reported_ships.make(0)
                    until ship.is_off loop
                        if ship.item.size >= closest then
                            detected_ships := detected_ships + 1
                            s.serialize("ii", <<ship.item.size, ship.item.picture>>)
                            reported_ships.append (s.serialized_form)
                        end
                        ship.next
                    end
                    if detected_ships > 0 then
                        detected_fleets := detected_fleets + 1
                        s.serialize("iiii", <<alienfleet.item.owner, alienfleet.item.eta,
                                 alienfleet.item.destination, detected_ships>>)
                        reported_fleets.append (s.serialized_form)
                        reported_fleets.append (reported_ships)
                    end
                end
                alienfleet.next
            end
            s.serialize("i", <<detected_fleets>>)
            Result.append (s.serialized_form)
            Result.append (reported_fleets)
        end
    end



feature -- Access
    stars: ARRAY[S_STAR]

end -- S_GALAXY
