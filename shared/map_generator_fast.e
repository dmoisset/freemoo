class MAP_GENERATOR_FAST

inherit
    MAP_GENERATOR_V1

creation
    make

feature {NONE} -- Position Generation

    make_positions: ARRAY[COORDS] is
    local
        i: INTEGER
        newc: COORDS
    do
        !!Result.make (1, 0)

        -- Toss in stars anywhere
        from
        until
            Result.count = starcount
        loop
            newc := newcoords
            Result.add_last(newc)
        end

        -- Remove any bunch-up
        from
            i := Result.lower
        until
            i > Result.upper
        loop
            if bunched_up (Result.item (i), Result) then
                Result.remove (i)
            else
                i := i + 1
            end
        end

        -- Add in more to complete (carefully now)
        fill_carefully (Result)

        -- Remove any lone-ranger
        from
            i := Result.lower
        until
            i > Result.upper
        loop
            if too_far_away(Result.item(i), Result) then
                Result.remove(i)
            else
                i := i + 1
            end
        end

        -- Top up (carefully) and serve cold
        fill_carefully(Result)
    end

end -- MAP_GENERATOR_FAST
