class OPTION_LIST

creation
    make

feature -- Creation

    make is
        -- Empty option_list
    do
        !!bool_options.make
        !!int_options.make
        !!enum_options.make
        !!enum_options_names.make
        !!real_options.make
        !!string_options.make
        status := st_ok
    end

feature -- Access

    st_ok, st_notexists, st_type, st_last: INTEGER is unique
        -- Possible `status' values

    status: INTEGER
        -- Status of last operation: one of the st_ constants
        -- `st_ok': Operation succededed
        -- `st_notexists': option does not exists
        -- `st_type': Bad option type

    bool_options: SET [STRING]
        -- Boolean options

    int_options: DICTIONARY [INTEGER, STRING]
        -- Integer options

    enum_options: DICTIONARY [INTEGER, STRING]
        -- Enumerated options

    enum_options_names: DICTIONARY [STRING, STRING]
        -- Enumerated options by name

    real_options: DICTIONARY [REAL, STRING]
        -- Real options

    string_options: DICTIONARY [STRING, STRING]
        -- String options

feature -- Operations

    parse_add (s: STRING) is
        -- parse `s' as option spec and add/replace. Sets `status'
    require
        s /= Void
    local
        optname, optval: STRING
    do
        if s.has('=') then -- Split
            optname := s.substring (1, s.first_index_of ('=')-1)
            optval := s.substring (s.first_index_of ('=')+1, s.count)
            optname.left_adjust
            optname.right_adjust
            optval.left_adjust
            if not optval.is_empty and then optval @ 1 = '"' then
                optval.remove_first (1)
            else
                optval.right_adjust
            end
        else
            -- Perhaps a Boolean, will try that
            !!optname.copy (s)
            optname.left_adjust
            optname.right_adjust
            optval := "True"
        end
        optval.to_lower
        status := st_ok
        if options.has (optname) then
            inspect
                options @ optname
            when ot_bool then
                optval.to_lower
                if optval.is_equal ("true") or optval.is_equal ("yes") or
                   optval.is_equal ("1") then
                    bool_options.add (optname)
                elseif optval.is_equal ("false") or optval.is_equal ("no") or
                       optval.is_equal ("0") or optval.is_empty then
                    bool_options.remove (optname)
                else
                    status := st_type
                end
            when ot_integer then
                if optval.is_integer then
                    int_options.put (optval.to_integer, optname)
                else
                    status := st_type
                end
            when ot_real then
                if optval.is_real then
                    real_options.put (optval.to_real, optname)
                else
                    status := st_type
                end
            when ot_enum then
                optval.to_lower
                check enums.has (optname) end -- should be there
                if (enums @ optname).has (optval) then
                    enum_options.put (enums @ optname @ optval, optname)
                    enum_options_names.put (optval, optname)
                else
                    status := st_type
                end
            when ot_string then
                string_options.put (optval, optname)
            end -- inspect
        else
            status := st_notexists
        end
    end


feature {NONE} -- Constants

    ot_bool, ot_integer, ot_enum,
    ot_real, ot_string: INTEGER is unique
        -- option types

feature {NONE} -- Valid options and values

    options: DICTIONARY [INTEGER, STRING] is
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
    end

    enums: DICTIONARY [DICTIONARY [INTEGER, STRING], STRING] is
    local
        enum: DICTIONARY [INTEGER, STRING]
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
            enum.put (-1, "organicrich")
            enum.put ( 0, "average")
            enum.put ( 1, "mineralrich")
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

invariant
    enum_options.count = enum_options_names.count
    status.in_range (st_ok, st_last-1)

end -- class OPTION_LIST