class DUMB_CLIENT
    -- FreeMOO client for testing purposes (non-inteeractive)
    -- Assumes that connections won't ail and things like that

inherit
    CLIENT
    PROTOCOL
    GETTEXT
    STRING_FORMATTER

creation make

feature
    options: CLIENT_OPTIONS

feature

    get_options is
    local
        i: INTEGER
    do
        !!options.make
        -- Hardcoded defaults
        options.parse_add ("server=localhost")
        options.parse_add ("port=3002")
        options.parse_add ("name=dumb")
        options.parse_add ("password=*****")
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

    make is
    do
        get_options
        -- Start connection
        set_server (options.string_options @ "server",
                    options.int_options @ "port")
        print ("Starting connection...%N")
        -- Wait for connection to complete (may lock up)
        server.wait_connection (-1)
        if not server.is_closed then
            -- Main connection loop
            start
            join
            setup
            play
            cleanup
        else
            print ("Connection failed.%N")
        end
        cleanup
--    rescue
--        cleanup
    end

    start is
        -- First stage on connection: suscribe to basic services
    do
        -- Wait until basic data is available
        print ("Waiting for basic services...%N")
        from until
            server.has ("game_status") and server.has ("players_list")
        loop server.get_data (-1) end
        -- Subscribe to basic data
        print ("Subscribing to basic services...%N")
        server.subscribe_base
    end

    join is
        -- Second stage on connection: login
    do
        print ("Joining...%N")
        server.join (options.string_options @ "name",
                     options.string_options @ "password")
        from until server.is_joined or not server.is_joining loop
            server.get_data (-1)
        end
        if not server.is_joined then
            print ("Can't join: ")
            print (join_reject_causes @ server.join_reject_cause)
            print ("%N")
        else
            print ("Joined%N")
        end
    end

    setup is
        -- Last stage on connection. Setup of player parameters (color, race, 
        -- etc.) and start of game
    do
        print ("Starting game...%N")
        server.set_ready
        print ("Waiting for other players...%N")
        from until
            server.game_status.started
        loop server.get_data (-1) end
    end

    play is
    do
        print ("Playing now%N")
        from until false loop server.get_data (-1) end
    end

    cleanup is
    do
        if server /= Void and then not server.is_closed then
            server.close
        end
    end

    join_reject_causes: ARRAY [STRING] is
    once
        !!Result.make (reject_cause_duplicate, reject_cause_last)
        Result.put (l("Another player with that name is playing"), reject_cause_duplicate)
        Result.put (l("No room for more players"), reject_cause_noslots)
        Result.put (l("Game has finished"), reject_cause_finished)
        Result.put (l("Access denied"), reject_cause_denied)
        Result.put (l("You are already logged in"), reject_cause_relog)
        Result.put (l("That player is already logged in"), reject_cause_alreadylog)
    end


end -- class DUMB_CLIENT