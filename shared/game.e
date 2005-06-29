class GAME
    -- Main game class

inherit
    PLAYER_CONSTANTS
    DIALOG_HANDLER [FM_DIALOG]

feature {NONE} -- Creation

    make_with_options (opt: SERVER_OPTIONS) is
    do
        options := opt
        !!status.make_with_options (options)
        !!players.make
        !!galaxy.make
        make_mapgenerator
        make_evolver
        make -- Dialog handler
    end

    make_mapgenerator is
    require
        options /= Void
        options.enum_options_names.has ("mapgen")
    local
        genname: STRING
    do
        genname := options.enum_options_names @ "mapgen"
        if genname.is_equal ("slow1") then
            !MAP_GENERATOR_SLOW!map_generator.make (options)
        elseif genname.is_equal ("fast1") then
            !MAP_GENERATOR_FAST!map_generator.make (options)
        else
-- see what to do here
           check False end
        end
    ensure
        map_generator /= Void
    end

    make_evolver is
    require
        options /= Void
        options.enum_options_names.has ("starttech")
    local
        evoname: STRING
    do
        evoname := options.enum_options_names @ "starttech"
        if evoname.is_equal ("prewarp") then
            !EVOLVER_PREWARP!evolver.make (options)
--not implemented
        elseif evoname.is_equal ("medium") then
        --    !EVOLVER_MEDIUM!evolver.make (options)
        elseif evoname.is_equal ("advanced") then
        --    !EVOLVER_ADVANCED!evolver.make (options)
        else
-- see what to do here
           check False end
        end
    ensure
        evolver /= Void
    end

feature -- Access

    status: GAME_STATUS
        -- Status of the game

    players: PLAYER_LIST [PLAYER]
        -- Players in the game

    galaxy: GALAXY
        -- Galaxy where the game is played

    end_condition: BOOLEAN is
        -- has reached end condition?
    local
        ip: ITERATOR [PLAYER]
        ist: ITERATOR [STAR]
        count: INTEGER
    do
        -- Only one survivor or
        -- Somebody was elected or
        -- Somebody defeated the antarans

        -- for now we use "some player explored everything"
        -- Count stars that are not blackholes
        from ist := galaxy.get_new_iterator_on_stars until
           ist.is_off
        loop
           if ist.item.kind /= ist.item.kind_blackhole then
               count := count + 1
           end
           ist.next
        end
        -- Check players
        from ip := players.get_new_iterator until ip.is_off or Result loop
            Result := ip.item.knows_star.count = count
            ip.next
        end
    end

    winner: PLAYER is
    require
        end_condition
    do
-- Not implemented
    end

feature -- Operations

    set_player_ready (player: PLAYER) is
    require
        player /= Void
        players.has (player.name)
        not status.finished
    do
        players.set_player_state (player, st_ready)
        if players.all_in_state (st_ready) and status.open_slots = 0 then
            -- Generate Galaxy
            map_generator.generate (galaxy, players)
            evolver.evolve (players.get_new_iterator)
--FIXME: Start what has to start
            init_game
            status.start
            players.set_all_state (st_playing_turn)
        end
    end

    add_player (player: PLAYER) is
        -- Add `player' to player list
    do
        players.add (player)
        status.fill_slot
    end

    end_turn (player: PLAYER) is
    require
        player /= Void
        players.has (player.name)
        not status.finished
--        player.state = player.playing_turn
-- Server used to break with this precondition. See what to do about it.
    do
        players.set_player_state (player, st_waiting_turn_end)
-- FIXME!!! take care with getting this twice in a turn
        if players.all_in_state (st_waiting_turn_end) then
            new_turn
        end
    end

    do_turn_step is
        -- Move forward in the end of turn sequence
    do
        from until not dialogs.is_empty or new_turn_step = turn_done loop
            inspect
                new_turn_step
            when 0 then new_turn_0
            when 1 then new_turn_1
            when 2 then new_turn_2
            when 3 then new_turn_3
            when turn_done then print ("do_turn_step: Turn already finished.%N")
            end
        end
    end

feature {NONE} -- Internal

    map_generator: MAP_GENERATOR

    evolver: EVOLVER

    options: SERVER_OPTIONS

    new_turn is
        -- start the end of turn sequence
    do
        new_turn_step := 0
        do_turn_step
    end

    new_turn_step: INTEGER
        -- stage inside the end of turn sequence

    turn_done: INTEGER is 4
        -- last stage of turn passing

    new_turn_0 is
        -- Calculate new turn, step 0
    require
        new_turn_step = 0
    do
        colony_new_turn
        move_fleets
        -- After this:
        -- Ask where to combat (dialog)
        new_turn_step := new_turn_step + 1
    end
    
    new_turn_1 is
    require
        new_turn_step = 1
    do
        -- Assign fleet combats
        -- After this:
        -- Solve combat (dialog)
        -- Solve bombardment/ground combat (dialog)
        new_turn_step := new_turn_step + 1
    end

    new_turn_2 is
    require
        new_turn_step = 2
    do
        -- Bombardment/ground combat
        -- After this:
        -- ask where to colonize (dialog)
        new_turn_step := new_turn_step + 1
    end
    
    new_turn_3 is
    require
        new_turn_step = 3
    do
        -- Colonization
        colonize_all
        -- Generate data for new turn
        galaxy.generate_scans (players.get_new_iterator)
        galaxy.generate_colony_knowledge(players.get_new_iterator)
        -- Move on, or finish
        status.next_date
        if not end_condition then
            players.set_all_state (st_playing_turn)
            save
        else
            players.set_all_state (st_end_game)
            status.finish
        end
        new_turn_step := new_turn_step + 1
    end

    colony_new_turn is
        -- Advance turn for colonies
    local
        s: ITERATOR [like star_type]
        p: ITERATOR [like planet_type]
        f: ITERATOR [like fleet_type]
        fleet: like fleet_type
    do
        s := galaxy.get_new_iterator_on_stars
        from s.start until s.is_off loop
            p := s.item.get_new_iterator_on_planets
            from p.start until p.is_off loop
                if p.item /= Void and then p.item.colony /= Void then
                    p.item.colony.new_turn
                    if p.item.colony.shipyard /= Void then
                        from
                            f := galaxy.get_new_iterator_on_fleets
                        until
                            f.is_off or else 
                            (f.item.owner = p.item.colony.owner and
                             f.item.orbit_center = s.item and
                             f.item.destination = Void)
                        loop
                            f.next
                        end
                        if not f.is_off then
                            f.item.add_ship(p.item.colony.shipyard)
                        else
                            fleet := galaxy.create_fleet
                            fleet.set_owner(p.item.colony.owner)
                            fleet.enter_orbit(s.item)
                            fleet.add_ship(p.item.colony.shipyard)
                            galaxy.add_fleet(fleet)
                        end
                        p.item.colony.clear_shipyard
                    end
                end
                p.next
            end
            s.next
        end
    end

    colonize_all is
        -- Colonization
    local
        candidates: DICTIONARY[SET[S_COLONY_SHIP], S_PLANET]
        fleet_back_reference: DICTIONARY[S_FLEET, S_COLONY_SHIP]
        colony_ship: S_COLONY_SHIP
        f_it: ITERATOR[S_FLEET]
        s_it: ITERATOR[S_SHIP]
        cs_it: ITERATOR[S_COLONY_SHIP]
        ships: ITERATOR[SET[S_COLONY_SHIP]]
    do
        create candidates.make
        create fleet_back_reference.make
        -- First Build a list of candidates
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
                if colony_ship /= Void and then colony_ship.will_colonize /= Void then
                    if f_it.item.destination = Void and
                       f_it.item.orbit_center /= Void and then
                       colony_ship.will_colonize.orbit_center = f_it.item.orbit_center then
                        if not candidates.has(colony_ship.will_colonize) then
                            candidates.add(create {SET[S_COLONY_SHIP]}.make, colony_ship.will_colonize)
                        end
                        candidates.reference_at(colony_ship.will_colonize).add(colony_ship)
                        fleet_back_reference.add(f_it.item, colony_ship)
                    else
                        colony_ship.set_will_colonize(Void)
                    end
                end
                s_it.next
            end
            f_it.next
        end
        -- Do Colonization or cancel draws
        from
            ships := candidates.get_new_iterator_on_items
        until
            ships.is_off
        loop
            if ships.item.count = 1 then
                colony_ship := ships.item.item(ships.item.lower)
                colony_ship.colonize
                fleet_back_reference.at(colony_ship).remove_ship(colony_ship)
            else
                from
                    cs_it := ships.item.get_new_iterator
                until
                    cs_it.is_off
                loop
                    cs_it.item.set_will_colonize(Void)
                    cs_it.next
                end
            end
            ships.next
        end
    end

    move_fleets is
        -- Fleet movement
    local
        i: ITERATOR [like fleet_type]
        old_in_orbit: BOOLEAN
    do
        i := galaxy.get_new_iterator_on_fleets
        from i.start until i.is_off loop
            old_in_orbit := i.item.is_in_orbit
            i.item.move
            if not old_in_orbit and i.item.is_in_orbit then
                galaxy.join_fleets (i.item.orbit_center)
            end
            i.next
        end
        galaxy.fleet_cleanup
    end
    
    init_game is
        -- Called just before setting players state to playing for the
        -- first time
    do
        galaxy.generate_scans (players.get_new_iterator)
        galaxy.generate_colony_knowledge (players.get_new_iterator)
    end

feature -- Saving

    hash_code: INTEGER is
    do
        Result := Current.to_pointer.hash_code
    end
    
feature {NONE} -- Internal - Saving
    
    save is
    do
    end
    
feature {NONE} -- Internal

    fleet_type: FLEET
        -- Just an anchor for typing of fleets

    star_type: STAR
        -- Just an anchor for typing of stars
    
    planet_type: PLANET
        -- Just an anchor for typing of planets
    
invariant
    map_generator /= Void
    new_turn_step.in_range (0, turn_done)

end -- class GAME
