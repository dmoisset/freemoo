deferred class EVOLVER

feature {NONE} -- Creation

    make (options: SERVER_OPTIONS) is
    require
        options /= Void
    deferred
    end

feature -- Operations

    evolve (players: ITERATOR [PLAYER]) is
        -- Configure `players' to initial state.
    require
        players /= Void
    deferred
    end

end -- class EVOLVER