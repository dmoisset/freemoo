class GAME
    -- Main game class

inherit
    PLAYER_CONSTANTS

feature {NONE} -- Creation

    make_with_options (opt: OPTION_LIST) is
    do
        options := opt
        !!status.make_with_options (options)
        !!players.make
        !!galaxy.make
        make_mapgenerator
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
feature -- Access

    status: GAME_STATUS
        -- Status of the game

    players: PLAYER_LIST [PLAYER]
        -- Players in the game

    galaxy: GALAXY
        -- Galaxy where the game is played

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
--FIXME: Start what has to start
            print ("gogogo!!%N")
            status.start
        end
    end

    add_player (p: PLAYER) is
        -- Add `p' to player list
    do
        players.add (p)
        status.fill_slot
    end

    new_turn is
        -- Calculate new turn
    do
        colony_new_turn
        move_fleets
        -- Fleet combat
        -- Bombardment/ground combat
        -- Colonization
        status.next_date
    end

feature {NONE} -- Internal

    map_generator: MAP_GENERATOR

    options: OPTION_LIST

    colony_new_turn is
        -- Advance turn for colonies
    local
        s, p: INTEGER
        star: STAR
        planet: PLANET
    do
        from s := galaxy.stars.lower until s > galaxy.stars.upper loop
            star := galaxy.stars @ s
            from p := star.planets.lower until s > star.planets.upper loop
                planet := star.planets @ p
                if planet.colony /= Void then
                    planet.colony.new_turn
                end
                p := p + 1
            end
            s := s + 1
        end
    end

    move_fleets is
        -- Fleet movement
    local
        i: ITERATOR [SHIP]
    do
        i := galaxy.ships.get_new_iterator_on_items
        from i.start until i.is_off loop
            i.item.move
            i.next
        end
    end

invariant
    map_generator /= Void

end -- class GAME