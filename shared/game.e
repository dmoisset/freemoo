class GAME
    -- Main game class

inherit
    PLAYER_CONSTANTS
    DIALOG_HANDLER [FM_DIALOG]
        redefine remove_dialog end

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
            Result := ip.item.has_visited_star.count = count
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

feature {DIALOG} -- Operations

    remove_dialog (d: FM_DIALOG) is
    do
        Precursor (d)
        if new_turn_step < turn_done then
            do_turn_step
        end
    end

feature -- Combat resolution

    attacks: HASHED_DICTIONARY [COMBAT_RESOLUTION, STAR]
        -- Initiative for each star

    pending_attacks: INTEGER
        -- Number of attacks left to solve this round
    
    pending_at: HASHED_DICTIONARY [INTEGER, STAR]
        -- Number of attacks that can be solved now at each star

    init_attacks is
    local
        s: ITERATOR [STAR]
        r: COMBAT_RESOLUTION
    do
        if attacks = Void then create attacks.make end
        if pending_at = Void then create pending_at.make end
        from s := galaxy.get_new_iterator_on_stars until s.is_off loop
            if attacks.has (s.item) then
                attacks.at (s.item).clear
            else
                create r.make (players)
                attacks.put (r, s.item)
            end
            attacks.at (s.item).set_colonized_from (s.item)
            attacks.at (s.item).set_turn (status.date)
            pending_at.put (0, s.item)
            s.next
        end
        pending_attacks := 0
    end

    add_attack (attacker, defender: PLAYER; location: STAR) is
    require
        attacks /= Void
        galaxy.has_star (location.id)
        players.has_id (attacker.id)
        players.has_id (defender.id)
    do
        attacks.at (location).add_combat (attacker, defender)
        pending_attacks := pending_attacks + 1
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
    local
        f: ITERATOR [FLEET]
    do
        colony_new_turn
        move_fleets
        galaxy.generate_scans (players.get_new_iterator)
        galaxy.generate_colony_knowledge(players.get_new_iterator)
        -- After this:
        -- Ask where to combat (dialog)
        init_attacks
        from f := galaxy.get_new_iterator_on_fleets until f.is_off loop
            if
                f.item.has_engage_orders and then
                f.item.has_target_at (galaxy)
            then
                add_dialog (create {ENGAGE_DIALOG}.make(f.item, Current))
                f.item.cancel_engage_order
            end
            f.next
        end
        
        new_turn_step := new_turn_step + 1
    end

    new_turn_1 is
    require
        new_turn_step = 1
    local
        s: ITERATOR [STAR]
        ps: ARRAY [PLAYER]
    do
        if pending_attacks > 0 then
            -- Assign fleet combats
            from s := galaxy.get_new_iterator_on_stars until s.is_off loop
                if pending_at @ s.item = 0  and attacks.at (s.item).count > 0 then
                    -- New round of attacks at s
                    ps := attacks.at (s.item).next_attackers
                    ps.do_all (agent start_combat (s.item, ?))
                end
                s.next
            end
        else
            -- After this:
            -- Solve combat (dialog)
            -- Solve bombardment/ground combat (dialog)
            new_turn_step := new_turn_step + 1
        end
    end

    new_turn_2 is
    require
        new_turn_step = 2
    local
        f: ITERATOR [FLEET]
    do
        -- Bombardment/ground combat
        -- After this:
        -- ask where to colonize (dialogs)
        from f := galaxy.get_new_iterator_on_fleets until f.is_off loop
            if
                f.item.has_colonization_orders and then
                f.item.orbit_center.has_colonizable_planet
            then
                add_dialog (create {COLONIZATION_DIALOG}.make(f.item))
                f.item.cancel_colonize_order
            end
            f.next
        end
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
        fleet: like fleet_type
    do
        s := galaxy.get_new_iterator_on_stars
        from s.start until s.is_off loop
            p := s.item.get_new_iterator_on_planets
            from p.start until p.is_off loop
                if p.item /= Void and then p.item.colony /= Void then
                    p.item.colony.new_turn
                    if p.item.colony.shipyard /= Void then
                        fleet := galaxy.local_fleet (s.item, p.item.colony.owner)
                        if fleet /= Void  then
                            fleet.add_ship(p.item.colony.shipyard)
                        else
                            fleet := galaxy.create_fleet
                            fleet.set_owner(p.item.colony.owner)
                            fleet.enter_orbit(s.item)
                            fleet.add_ship(p.item.colony.shipyard)
                            galaxy.add_fleet(fleet)
                        end
                        p.item.colony.clear_shipyard
                    end
                    if p.item.colony.populators.count = 0 then
                        p.item.colony.remove
                        -- This colony has just starved to death.
                        -- Add something to the end-of-turn summary?
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
--FIXME: S_stuff here?!
        candidates: HASHED_DICTIONARY[HASHED_SET[S_COLONY_SHIP], S_PLANET]
        fleet_back_reference: HASHED_DICTIONARY[FLEET, COLONY_SHIP]
        colony_ship: S_COLONY_SHIP
        f_it: ITERATOR[FLEET]
        s_it: ITERATOR[SHIP]
        cs_it: ITERATOR[COLONY_SHIP]
        ships: ITERATOR[HASHED_SET[S_COLONY_SHIP]]
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
                            candidates.add(create {HASHED_SET[S_COLONY_SHIP]}.make, colony_ship.will_colonize)
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
        old_orbit: STAR
    do
        i := galaxy.get_new_iterator_on_fleets
        from i.start until i.is_off loop
            old_orbit := i.item.orbit_center
            i.item.move
            if i.item.is_in_orbit and i.item.orbit_center /= old_orbit then
                if
                    i.item.orbit_center.has_colonizable_planet and
                    i.item.can_colonize
                then
                    i.item.colonize_order
                end
                if i.item.has_target_at (galaxy) then
                    i.item.engage_order
                end
                galaxy.join_fleets (i.item.orbit_center)
            end
            i.next
        end
        galaxy.fleet_cleanup
    end

    start_combat (location: STAR; attacker: PLAYER) is
    local
        f, g: FLEET
        c: COLONY
        p, q: INTEGER -- Attack power
    do
        -- Find fleet
        f := galaxy.local_fleet (location, attacker)
        if f /= Void then
            g := galaxy.local_fleet (location, f.will_engage)
            if f.will_engage_at /= Void then 
                c := f.will_engage_at.colony
            end
            p := f.offensive_power
            if c /= Void then 
                q := c.offensive_power (g)
                f.damage (q)
                c.damage (p, g)
            elseif g /= Void then
                q := g.offensive_power
                f.damage (q)
                g.damage (p)
            end
        end
        -- Combat complete
        attacks.at (location).remove_combat (attacker)
        pending_attacks := pending_attacks - 1
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
