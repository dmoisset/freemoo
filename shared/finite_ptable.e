class FINITE_PTABLE [E]
    -- Probabilities for a finite set of events of type E

inherit
    PROBABILITY_TABLE [E]

creation
    make

feature -- Creation

    make (items: ARRAY [TUPLE [INTEGER, E]]) is
        -- for each [p, x] in items, assign a weight of p to
        -- event x, i.e. P(x) = p/S, where S is the sum of first components
        -- of items.
    require
        items /= Void
        items.count >= 1
        -- forall i in items: i /= Void
        -- forall i in items: i >= 0
    local
        i: ITERATOR [TUPLE [INTEGER, E]]
    do
        probs := items
        i := items.get_new_iterator
        from
            sum := 0
            i.start
        until i.is_off loop
            sum := sum + i.item.first
            i.next
        end
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
    ensure
        Result /= Void
    end

feature {NONE} -- Representation

    probs: ARRAY [TUPLE [INTEGER, E]]
    sum: INTEGER

invariant
    probs /= Void
    probs.count >= 1
    -- forall i in probs: i /= Void
    -- forall i in probs: i.first >= 0

end -- deferred class FINITE_PTABLE