class CLIENT_OPTIONS

inherit
    OPTION_LIST

creation
    make

feature {NONE} -- Valid options and values

    options: DICTIONARY [INTEGER, STRING] is
    once
        !!Result.make
        Result.put (ot_integer, "port")
        Result.put (ot_string , "server")
        Result.put (ot_string , "name")
        Result.put (ot_string , "password")
    end

    enums: DICTIONARY [DICTIONARY [INTEGER, STRING], STRING] is
    once
        !!Result.make
    end

end -- class CLIENT_OPTIONS