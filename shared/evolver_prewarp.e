class EVOLVER_PREWARP

inherit
    EVOLVER

creation
    make

feature {NONE} -- Creation

    make (options: SERVER_OPTIONS) is
    do
    end

feature -- Operations

    evolve (players: PLAYER_LIST [PLAYER]) is
        -- Configure `players' to initial state.
    local
        i: ITERATOR[PLAYER]
        p: PLAYER
    do
        from
            i := players.get_new_iterator
            i.start
        until
            i.is_off
        loop
            p := i.item
            p.colonies.item(p.colonies.lower).set_producing (p.colonies.item(p.colonies.lower).product_starship)
            i.next
        end
    end

end -- class EVOLVER_PREWARP