class S_GAME

inherit
    GAME
    redefine
        status, players, galaxy, add_player, init_game
    end
    SERVER_ACCESS

creation
    make_with_options

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

feature {NONE} -- Internal

    init_game is
    do
        server.register_galaxy
    end

end -- class S_GAME