deferred class PROBABILITY_TABLE [E]
    -- Probabilities for events of type E

inherit
    RANDOM_ACCESS

feature -- Access

    item (p: DOUBLE): E is
        -- given F the cdf (cumulative distribution function) for this
        -- probability table (cdf is a function going from E to p, where
        -- 0<p<=1), compute F^(-1) (p)
    require
        valid_probability: p > 0 and p <= 1
    deferred
    ensure
        Result /= Void
    end

    random_item: E is
        -- Return random event with Current probabilities
    do
        rand.next
        Result := item (rand.last_double)
    ensure
        Result /= Void
    end

end -- deferred class PROBABILITY_TABLE
