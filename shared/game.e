class GAME
    -- Main game class

inherit
    PLAYER_CONSTANTS

feature {NONE} -- Creation

    make_with_options (opt: SERVER_OPTIONS) is
    do
        options := opt
        !!status.make_with_options (options)
        !!players.make
        !!galaxy.make
        make_mapgenerator
        make_evolver
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
        if players.all_in_state (st_waiting_turn_end) then
            new_turn
        end
    end

    new_turn is
        -- Calculate new turn
    do
        colony_new_turn
        move_fleets
        -- Fleet combat
        -- Bombardment/ground combat
        -- Colonization
        galaxy.generate_scans (players.get_new_iterator)
	galaxy.generate_colony_knowledge(players.get_new_iterator)
        status.next_date
        if not end_condition then
            players.set_all_state (st_playing_turn)
	    save
        else
            players.set_all_state (st_end_game)
            status.finish
        end
    end

feature {NONE} -- Internal

    map_generator: MAP_GENERATOR

    evolver: EVOLVER

    options: SERVER_OPTIONS

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
                            f := s.item.get_new_iterator_on_fleets
                        until
                            f.is_off or else 
                            (f.item.owner = p.item.colony.owner and
                             f.item.destination = Void -- This will have to be changed when relocations are implemented
                            )
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

end -- class GAME
