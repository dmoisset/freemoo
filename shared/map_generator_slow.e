class MAP_GENERATOR_SLOW

inherit
    MAP_GENERATOR_V1

creation
    make

feature {NONE} -- Position Generation

    make_positions: ARRAY[COORDS] is
    do
        !!Result.make (1, 0)
        fill_carefully (Result)
    end

end -- class MAP_GENERATOR_SLOW
