class S_GAME

inherit
    GAME
    redefine
        status, players, add_player
    end

creation
    make_with_options

feature -- Access

    status: S_GAME_STATUS
        -- Status of the game

    players: S_PLAYER_LIST
        -- Players in the game

feature -- Operations

    add_player (p: S_PLAYER) is
        -- Add `p' to player list
    do
        players.add (p)
        status.fill_slot
    end


end -- class S_GAME