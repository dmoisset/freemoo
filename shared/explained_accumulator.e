class EXPLAINED_ACCUMULATOR[E->NUMERIC]
    -- An accumulator in which every subtotal has a reason

creation make

feature -- Access

    total: E

    get_new_iterator_on_reasons: ITERATOR[STRING] is
    do
        Result := subtotals.get_new_iterator_on_keys
    end

    get_amount_due_to, infix "@" (reason: STRING): E is
    require
        reason /= Void
    do
        if subtotals.has(reason) then
            Result := subtotals.at(reason)
        end
    end

feature -- Operations

    add(amount: E; reason: STRING) is
    require
        reason /= Void
    local
        new_subtot: E
    do
        new_subtot := get_amount_due_to(reason) + amount
        if new_subtot = 0 then
            subtotals.remove(reason)
        else
            subtotals.put(new_subtot, reason)
        end
        total := total + amount
    ensure
        (old get_amount_due_to(reason) + amount - get_amount_due_to(reason)).abs < 0.000001
        (total - (old total + amount)).abs < 0.000001 -- I really, really hate this hack
    end

    eliminate(reason: STRING) is
    require
        reason /= Void
    do
        total := total - get_amount_due_to(reason)
        subtotals.remove(reason)
    ensure
        get_amount_due_to(reason) = 0
        total = old total - old get_amount_due_to(reason)
    end

    clear is
    do
        subtotals.clear
        total := 0
    ensure
        total = 0
    end

feature {NONE} -- Creation

    make is
    do
        create subtotals.make
    end

feature {NONE} -- Implementation

    subtotals: HASHED_DICTIONARY[E, STRING]

invariant
    subtotals /= Void
end -- class EXPLAINED_ACCUMULATOR
