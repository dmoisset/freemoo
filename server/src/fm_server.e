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

    register_galaxy is
    do
        register (game.galaxy, "galaxy")
    end

feature -- Redefined features

    new_connection: FM_SERVER_CONNECTION is
    do
        !!Result.make (Current)
        std_error.put_string (format (l("New connection from ~1~:~2~%N"),
                                      <<Result.dq_address, Result.port>>))
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
        !!game.make_with_options (options)
        register (game.status, "game_status")
        register (game.players, "players_list")
    end

feature -- Server attributes

    game: S_GAME

    options: SERVER_OPTIONS

end -- class FM_SERVER