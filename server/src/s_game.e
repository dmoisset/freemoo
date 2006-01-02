class S_GAME

inherit
    GAME
        redefine
            status, players, galaxy, add_player, init_game,
            fleet_type, star_type, planet_type, save,
            add_dialog, remove_dialog, make_evolver, colonize_all
        end
    SERVER_ACCESS
    STORABLE
        redefine dependents end
    SERVICE
        redefine subscription_message end

creation
    make_with_options

feature {NONE} -- Creation


    make_evolver is
    local
        evoname: STRING
    do
        evoname := options.enum_options_names @ "starttech"
        if evoname.is_equal ("prewarp") then
            !S_EVOLVER_PREWARP!evolver.make (options)
--not implemented
        elseif evoname.is_equal ("medium") then
        --    !EVOLVER_MEDIUM!evolver.make (options)
        elseif evoname.is_equal ("advanced") then
        --    !EVOLVER_ADVANCED!evolver.make (options)
        else
-- see what to do here
           check False end
        end
    end

feature -- Access

    status: S_GAME_STATUS
        -- Status of the game

    players: S_PLAYER_LIST
        -- Players in the game

    galaxy: S_GALAXY

feature -- Operations

    add_player (p: S_PLAYER) is
        -- Add `p' to player list
    do
        players.add (p)
        status.fill_slot
    end

    init_game is
    local
        i: ITERATOR [S_PLAYER]
        j: ITERATOR [like star_type]
        f: ITERATOR [like fleet_type]
        s: ITERATOR [S_SHIP]
    do
        -- This feature is public because it must be called from FM_SERVER
        -- when loading a game
        Precursor
        -- Register galaxy
        server.register (galaxy, "galaxy")
        -- Register player-specific services
        i := players.get_new_iterator
        from i.start until i.is_off loop
            server.register (i.item, i.item.color.to_string+":turn_summary")
            server.register (galaxy, i.item.id.to_string+":scanner")
            server.register (galaxy, i.item.id.to_string+":enemy_colonies")
            server.register (galaxy, i.item.id.to_string+":new_fleets")
            server.register (Current, i.item.id.to_string+":dialogs")
            server.register (i.item.race, "race" + i.item.race.id.to_string)
            server.register (i.item, "player"+i.item.id.to_string)
            i.next
        end
        -- Register stars
        j := galaxy.get_new_iterator_on_stars
        from j.start until j.is_off loop
            server.register (j.item, "star"+j.item.id.to_string)
            j.next
        end
        -- Register fleets and ships
        from
            f := galaxy.get_new_iterator_on_fleets
        until f.is_off loop
            from
                s := f.item.get_new_iterator
            until s.is_off loop
                server.register(s.item, "ship" + s.item.id.to_string)
                s.next
            end
            f.next
        end
    end

    colonize_all is
    local
        fleet_back_reference: HASHED_DICTIONARY[FLEET, COLONY_SHIP]
        candidates: HASHED_DICTIONARY[HASHED_SET[S_COLONIZER], S_PLANET]
        colony_ship: S_COLONY_SHIP
        colonizer: S_COLONIZER
        f_it: ITERATOR[S_FLEET]
        s_it: ITERATOR[S_SHIP]
        p_it: ITERATOR[S_PLAYER]
        cs_it: ITERATOR[S_COLONIZER]
        colonizers: ITERATOR[HASHED_SET[S_COLONIZER]]
    do
        create candidates.make
        create fleet_back_reference.make
        -- First Build a list of candidates
        -- (from fleets...)
        from
            f_it := galaxy.get_new_iterator_on_fleets
        until
            f_it.is_off
        loop
            from
                s_it := f_it.item.get_new_iterator
            until
                s_it.is_off
            loop
                colony_ship ?= s_it.item
                if colony_ship /= Void and then colony_ship.planet_to_colonize /= Void then
                    if f_it.item.destination = Void and
                       f_it.item.orbit_center /= Void and then
                        colony_ship.planet_to_colonize.orbit_center = f_it.item.orbit_center then
                        if not candidates.has(colony_ship.planet_to_colonize) then
                            candidates.add(create {HASHED_SET[S_COLONIZER]}.make, colony_ship.planet_to_colonize)
                        end
                        candidates.reference_at(colony_ship.planet_to_colonize).add(colony_ship)
                        fleet_back_reference.add(f_it.item, colony_ship)
                    else
                        colony_ship.set_planet_to_colonize(Void)
                    end
                end
                s_it.next
            end
            f_it.next
        end
        -- (from colonies...)
        from
            p_it := players.get_new_iterator
        until
            p_it.is_off
        loop
            from
                cs_it := p_it.item.colonies.get_new_iterator_on_items
            until
                cs_it.is_off
            loop
                if cs_it.item.planet_to_colonize /= Void then
                    if not candidates.has(cs_it.item.planet_to_colonize) then
                        candidates.add(create {HASHED_SET[S_COLONIZER]}.make, cs_it.item.planet_to_colonize)
                    end
                    candidates.reference_at(cs_it.item.planet_to_colonize).add(cs_it.item)
                end
                cs_it.next
            end
            p_it.next
        end
        -- Do Colonization or cancel draws
        from
            colonizers := candidates.get_new_iterator_on_items
        until
            colonizers.is_off
        loop
            if colonizers.item.count = 1 then
                colonizer := colonizers.item.item(colonizers.item.lower)
                colony_ship ?= colonizer
                if colony_ship /= Void then
                    fleet_back_reference.at(colony_ship).remove_ship(colony_ship)
                end
                colonizer.colonize
            else
                from
                    cs_it := colonizers.item.get_new_iterator
                until
                    cs_it.is_off
                loop
                    cs_it.item.set_colonization_orders(False)
                    cs_it.next
                end
            end
            colonizers.next
        end
    end

feature {NONE} -- Constants -- dialog service

    dialog_remove: INTEGER is 0
    dialog_add: INTEGER is 1
    dialog_list: INTEGER is 2
-- FIXME: this is duplicated with DIALOG_HANDLER

feature -- Operations -- dialog service

    subscription_message (service_id: STRING): STRING is
        -- Complete list of dialogs for player
    require
        service_id.has_suffix (":dialogs")
        service_id.substring (1, service_id.count-8).is_integer
    local
        s: SERIALIZER2
        l: LINKED_LIST [FM_DIALOG]
        i: ITERATOR [FM_DIALOG]
        player_id: INTEGER
    do
        player_id := service_id.substring (1, service_id.count-8).to_integer
        create s.make
        create l.make
        s.add_integer (dialog_list)
        -- Find dialogs for this player
        from i := dialogs.get_new_iterator_on_items until i.is_off loop
            if i.item.player.id = player_id then
                l.add_last (i.item)
            end
            i.next
        end
        -- Serialize dialog list
        s.add_integer (l.count)
        from i := l.get_new_iterator until i.is_off loop
            s.add_integer (i.item.id)
            s.add_integer (i.item.kind)
            s.add_string (i.item.info)
            i.next
        end
        Result := s.serialized_form
    end

feature {DIALOG} -- Operations -- dialog service

    add_dialog (d: FM_DIALOG) is
    local
        s: SERIALIZER2
    do
        Precursor (d)
        create s.make
        s.add_integer (dialog_add)
        s.add_integer (d.id)
        s.add_integer (d.kind)
        s.add_string (d.info)
        send_message(d.player.id.to_string+":dialogs", s.serialized_form)
    end

    remove_dialog (d: FM_DIALOG) is
    local
        s: SERIALIZER2
    do
        create s.make
        s.add_integer (dialog_remove)
        s.add_integer (d.id)
        send_message(d.player.id.to_string+":dialogs", s.serialized_form)
        Precursor (d)
    end

feature {STORAGE} -- Saving

    get_class: STRING is "GAME"

    fields: ITERATOR[TUPLE[STRING, ANY]] is
    local
        a: ARRAY[TUPLE[STRING, ANY]]
    do
        create a.make(1, 0)
        a.add_last(["status", status])
        a.add_last(["players", players])
        a.add_last(["galaxy", galaxy])
        Result := a.get_new_iterator
    end

    dependents: ITERATOR[STORABLE] is
    local
        a: ARRAY[STORABLE]
    do
        create a.make(1, 0)
        a.add_last(status)
        a.add_last(players)
        a.add_last(galaxy)
        Result := a.get_new_iterator
    end

feature {STORAGE} -- Operations - Retrieving

    set_primary_keys (elems: ITERATOR [TUPLE [STRING, ANY]]) is
    do
    end

    make_from_storage (elems: ITERATOR [TUPLE [STRING, ANY]]) is
    do
        from
        until elems.is_off loop
            if elems.item.first.is_equal("status") then
                status ?= elems.item.second
            elseif elems.item.first.is_equal("players") then
                players ?= elems.item.second
            elseif elems.item.first.is_equal("galaxy") then
                galaxy ?= elems.item.second
            end
            elems.next
        end
        if galaxy = Void or players = Void or status = Void then
            print("game.e:  Called make_from_storage with nonsensical elems!")
        end
    end

feature {NONE} -- Operations - Saving

    save is
    do
        save_with_filename("freeMOO_autosave_" + status.date.to_string + ".xml")
    end

    save_with_filename(filename: STRING) is
    local
        st: STORAGE_XML
    do
        create st.make_with_filename(filename)
        st.store(Current)
    end

feature {NONE} -- Internal

    fleet_type: S_FLEET

    star_type: S_STAR

    planet_type: S_PLANET

end -- class S_GAME
