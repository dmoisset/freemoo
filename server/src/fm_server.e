class FM_SERVER

inherit
    NETWORK_SERVICE_REGISTRY
    redefine
        make,
        new_connection
    end
    GETTEXT
    STRING_FORMATTER
    PKG_USER

creation make

feature {NONE} -- Creation

    make is
    do
        std_error.put_string (l("FreeMOO server v0.1 started%N"))
        pkg_system.make_with_config_file ("freemoo.conf")
        init
        Precursor
    end

feature -- Operations

    run is
    do
        net_initialize
        std_error.put_string (l("FreeMOO server v0.1 ready and listening%N"))
        from until False loop
            get_connection_or_data (-1)
            cleanup
        end
        deafen
        close_all
--    rescue
--        deafen
--        close_all
    end

feature -- Redefined features

    new_connection: FM_SERVER_CONNECTION is
    do
        !!Result.make (Current)
        std_error.put_string (format (l("New connection from ~1~:~2~%N"),
                                      <<Result.dq_address, Result.port.box>>))
    end

feature {NONE} -- Internal

    init is
    local
        i: INTEGER
    do
        !!options.make
        -- Hardcoded defaults
        options.parse_add ("maxplayers=8")
        options.parse_add ("galaxysize=huge")
        options.parse_add ("galaxyage=average")
        options.parse_add ("starttech=prewarp")
        options.parse_add ("mapgen=fast1")
        options.parse_add ("tactical")
        options.parse_add ("randomevs")
        options.parse_add ("antarans")
        -- Parse command line
        from i := 1 until i > argument_count loop
            options.parse_add (argument (i))
            if options.status /= options.st_ok then
                std_error.put_string(
                    format (l("Invalid option: ~1~%N"), <<argument (i)>>)
                )
            end
            i := i + 1
        end
    end

    net_initialize is
        -- Create all server attributes, publish them, etc.
    do
        if options.string_options.has("load") then
            load_game_from_file(options.string_options@"load")
        else
            !!game.make_with_options (options)
        end
        register (game.status, "game_status")
        register (game.players, "players_list")
    end
    
    load_game_from_file(filename: STRING) is
    local
        gme: S_GAME
        ply: S_PLAYER
        pln: S_PLANET
        str: S_STAR
        st: STORAGE_XML
    do
        create gme.make_with_options(options)
        create ply.make("prototype", "")
        create str.make_defaults
        create pln.make_standard(str)
        create st.make_with_filename(filename)
        -- Register class prototypes
        st.register(gme)                              -- S_GAME
        st.register(gme.galaxy)                       -- S_GALAXY
        st.register(gme.status)                       -- S_GAME_STATUS
        st.register(gme.players)                      -- S_PLAYER_LIST
        st.register(ply)                              -- S_PLAYER
        st.register(gme.galaxy.limit)                 -- COORDS
        st.register(str)                              -- S_STAR
        st.register(create {S_FLEET}.make)            -- S_FLEET
        st.register(pln)                              -- S_PLANET
        st.register(create {S_COLONY}.make(pln, ply)) -- S_COLONY
        st.register(create {S_STARSHIP}.make(ply))    -- S_STARSHIP
        st.register(create {S_COLONY_SHIP}.make(ply)) -- S_COLONY_SHIP
        st.register(create {S_RACE}.make)
        st.retrieve
        game ?= st.retrieved
        game.init_game
    end

feature -- Server attributes

    game: S_GAME

    options: SERVER_OPTIONS

end -- class FM_SERVER
