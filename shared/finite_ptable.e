class FINITE_PTABLE [E]
    -- Probabilities for a finite set of events of type E

inherit
    PROBABILITY_TABLE [E]

creation
    make

feature -- Creation

    make (items: ARRAY [TUPLE [INTEGER, E]]) is
    require
        items /= Void
        items.count >= 1
        -- No value in items is Void
        -- All values in first components of items are unique, greater then 0,
        -- less than or equal than 1000.
        -- One of items has 1000 as probability
    do
        probs := items
    end

feature -- Access

    item (p: DOUBLE): E is
    local
        curs: ITERATOR [TUPLE [INTEGER, E]]
        best: INTEGER
        choice: INTEGER
    do
        choice := (p * 1000 + 1).floor.min (1000)
        curs := probs.get_new_iterator
        from
            curs.start
            best := 1001
        until
            curs.is_off
        loop
            if curs.item.first.in_range (choice, best) then
                best := curs.item.first
                Result := curs.item.second
            end
            curs.next
        end
    ensure
        Result /= Void
    end

feature {NONE} -- Representation

    probs: ARRAY [TUPLE [INTEGER, E]]

invariant
    probs /= Void
    probs.count >= 1
    -- No value in probs is Void
    -- All values in first components of probs are unique, greater then 0,
    -- less than or equal than 1000.
    -- One of probs has 1000 as  probability

end -- deferred class FINITE_PTABLE