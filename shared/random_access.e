class RANDOM_ACCESS
-- Singleton random number generator

feature

    rand: STD_RAND is
        -- Random number generator
    local
        today, epoch: TIME
        valid: BOOLEAN
    once
        today.update
        valid := epoch.set (1970, 1, 1, 0, 0, 0)
            check valid end -- Because 1/1/1970 IS a valid date
        create Result.with_seed (epoch.elapsed_seconds (today).rounded)
    end

end --class RANDOM_ACCESS
