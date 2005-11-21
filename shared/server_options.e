class SERVER_OPTIONS

inherit
    OPTION_LIST

creation
    make

feature {NONE} -- Valid options and values

    options: HASHED_DICTIONARY [INTEGER, STRING] is
    once
        !!Result.make
        Result.put (ot_integer, "maxplayers")
        Result.put (ot_enum   , "galaxysize")
        Result.put (ot_enum   , "galaxyage")
        Result.put (ot_enum   , "starttech")
        Result.put (ot_enum   , "mapgen")
        Result.put (ot_bool   , "tactical")
        Result.put (ot_bool   , "randomevs")
        Result.put (ot_bool   , "antarans")
        Result.put (ot_string , "load")
    end

    enums: HASHED_DICTIONARY [HASHED_DICTIONARY [INTEGER, STRING], STRING] is
    local
        enum: HASHED_DICTIONARY [INTEGER, STRING]
    once
        !!Result.make
            -- Galaxy sizes
            !!enum.make
            enum.put (0, "small")
            enum.put (1, "medium")
            enum.put (2, "large")
            enum.put (3, "huge")
        Result.put (enum, "galaxysize")
            -- Galaxy ages
            !!enum.make
            enum.put (-1, "orgrich")
            enum.put ( 0, "average")
            enum.put ( 1, "minrich")
        Result.put (enum, "galaxyage")
            -- Tech levels
            !!enum.make
            enum.put (0, "prewarp")
            enum.put (1, "medium")
            enum.put (2, "advanced")
        Result.put (enum, "starttech")
            -- Map generators
            !!enum.make
            enum.put (0, "slow1")
            enum.put (1, "fast1")
        Result.put (enum, "mapgen")
    end

end -- class SERVER_OPTIONS
