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
    local
        i: ITERATOR [S_PLAYER]
    do
        server.register (galaxy, "galaxy")
        i := players.get_new_iterator
        from i.start until i.is_off loop
            server.register (galaxy, i.item.id.to_string+":scanner")
            i.next
        end
    end

end -- class S_GAME