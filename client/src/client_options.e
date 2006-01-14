class CLIENT_OPTIONS

inherit
    OPTION_LIST

creation
    make

feature {NONE} -- Valid options and values

    options: HASHED_DICTIONARY [INTEGER, STRING] is
    once
        !!Result.make
        Result.put (ot_integer, "port")
        Result.put (ot_string , "server")
        Result.put (ot_string , "name")
        Result.put (ot_string , "password")
        Result.put (ot_string , "racename")
        Result.put (ot_string , "rulername")
        Result.put (ot_integer, "racepicture")
        Result.put (ot_enum   , "color")
    end

    enums: HASHED_DICTIONARY [HASHED_DICTIONARY [INTEGER, STRING], STRING] is
    local
        colors: HASHED_DICTIONARY [INTEGER, STRING]
    once
        create Result.make
        create colors.make
        colors.put (0, "red")
        colors.put (1, "yellow")
        colors.put (2, "green")
        colors.put (3, "white")
        colors.put (4, "blue")
        colors.put (5, "brown")
        colors.put (6, "violet")
        colors.put (7, "orange")
        Result.put (colors, "color")
    end

end -- class CLIENT_OPTIONS