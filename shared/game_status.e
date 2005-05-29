class GAME_STATUS
    -- Public status of the server

creation
    make, make_with_options

feature {NONE} -- Creation

    make is
    do
    end

    make_with_options (options: SERVER_OPTIONS) is
    do
        open_slots       := options.int_options     @ "maxplayers"
        galaxy_size      := options.enum_options    @ "galaxysize"
        galaxy_age       := options.enum_options    @ "galaxyage"
        start_tech_level := options.enum_options    @ "starttech"
        tactical_combat  := options.bool_options.has ("tactical")
        random_events    := options.bool_options.has ("randomevs")
        antaran_attacks  := options.bool_options.has ("antarans")
    end

feature -- Access (server status)

    open_slots: INTEGER
        -- slots open for players

    started: BOOLEAN
        -- True after game has began

    finished: BOOLEAN
        -- True when game is closed

    date: INTEGER
        -- Turns since the beginning of the game

feature -- Access (game rules)

    galaxy_size: INTEGER
        -- From 0 (small) to 3 (huge)

    galaxy_age: INTEGER
        -- From -1 (organic rich) to +1 (mineral rich)

    start_tech_level: INTEGER
        -- From 0 (pre-warp) to 2 (advanced)

    tactical_combat, random_events, antaran_attacks: BOOLEAN

feature -- Operations

    fill_slot is
        -- fill_one_game_slot
    require
        open_slots > 0
        not finished
    do
        open_slots := open_slots-1
    end

    start is
        -- Begin game
    require
        open_slots = 0
        not finished
    do
        started := True
    end

    finish is
        -- End game
    require
        started
    do
        finished := True
    end

    next_date is
    require
        not finished
    do
        date := date + 1
    end

invariant
    started implies open_slots = 0
    finished implies started
    open_slots >= 0
    galaxy_size.in_range (0, 3)
    galaxy_age.in_range (-1, 1)
    start_tech_level.in_range (0, 2)
    date >= 0

end -- class GAME_STATUS
