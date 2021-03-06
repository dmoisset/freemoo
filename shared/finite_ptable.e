class FINITE_PTABLE [E]
    -- Probabilities for a finite set of events of type E

inherit
    PROBABILITY_TABLE [E]

creation
    make

feature -- Creation

    make is
        -- for each [p, x] in items, assign a weight of p to
        -- event x, i.e. P(x) = p/S, where S is the sum of first components
        -- of items.
    do
        !!probs.make (1, 0)
    end

feature -- Operations

    add (e: E; p: INTEGER) is
        -- add `e' to table with probability weight `p'
    require
        p >= 0
    do
        probs.add_last ([p, e])
        sum := sum + p
    end

feature -- Access

    item (p: DOUBLE): E is
    local
        curs: ITERATOR [TUPLE [INTEGER, E]]
        choice: INTEGER
    do
        choice := (p*sum).floor.min (sum-1)
        curs := probs.get_new_iterator
        from
            curs.start
        until choice < curs.item.first loop
            choice := choice - curs.item.first
            curs.next
        end
        Result := curs.item.second
    end

feature {NONE} -- Representation

    probs: ARRAY [TUPLE [INTEGER, E]]
    sum: INTEGER

invariant
    probs /= Void
    -- forall i in probs: i /= Void
    -- forall i in probs: i.first >= 0
    -- sum = sum of i.first for each i in probs

end -- deferred class FINITE_PTABLE