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

    evolve (players: ITERATOR [PLAYER]) is
        -- Configure `players' to initial state.
    local
        p: PLAYER
    do
        from until players.is_off loop
            p := players.item
            p.colonies.item(p.colonies.lower).set_producing (p.colonies.item(p.colonies.lower).product_starship)
            players.next
        end
    end

end -- class EVOLVER_PREWARP
