class EVOLVER_PREWARP

inherit
    EVOLVER

creation
    make

feature {NONE} -- Creation

    make (options: SERVER_OPTIONS) is
    require
        options /= Void
    do
    end

feature -- Operations

    evolve (players: PLAYER_LIST [PLAYER]) is
        -- Configure `players' to initial state.
    require
        players /= Void
    local
        i: ITERATOR[STRING]
        p: PLAYER
    do
        from
            i := players.names.get_new_iterator
            i.start
        until
            i.is_off
        loop
            p := players @ i.item
            p.colonies.item(p.colonies.lower).set_producing (p.colonies.item(p.colonies.lower).product_starship)
            i.next
        end
    end

end -- class EVOLVER_PREWARP