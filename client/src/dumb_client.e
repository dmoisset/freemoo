class DUMB_CLIENT
    -- FreeMOO client for testing purposes (non-interactive)
    -- Assumes that connections won't fail and things like that

inherit
    CLIENT
    PROTOCOL
    GETTEXT
    STRING_FORMATTER
    PLAYER_CONSTANTS
    DIALOG_KINDS
    PKG_USER
    ARGUMENTS

creation make

feature
    options: CLIENT_OPTIONS

feature

    get_options is
    local
        i: INTEGER
    do
        pkg_system.make_with_config_file ("freemoo.conf")
        create options.make
        -- Hardcoded defaults
        options.parse_add ("server=localhost")
        options.parse_add ("port=3002")
        options.parse_add ("name=dumb")
        options.parse_add ("password=*****")
        options.parse_add ("racename=Dimwits")
        options.parse_add ("racepicture=0")
        options.parse_add ("rulername=The bad guy")
        options.parse_add ("color=red")
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
    local
        f: CONNECTION_FACTORY
    do
        get_options
        -- Start connection
        !FM_CLIENT_CONNECTION_FACTORY!f
        set_server (options.string_options @ "server",
                    options.int_options @ "port", f)
        print ("Starting connection...%N")
        -- Wait for connection to complete (may lock up)
        server.wait_connection (-1)
        if not server.is_closed then
            -- Main connection loop
            start
            join
            if not server.has_joined then
                rejoin
            end
            if server.has_joined then
                setup
                play
                cleanup
            end
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
        from until server.has_joined or not server.is_joining loop
            server.get_data (-1)
        end
        if not server.has_joined then
            print ("Can't join: ")
            print (join_reject_causes @ server.join_reject_cause)
            print ("%N")
        else
            print ("Joined%N")
        end
    end

    rejoin is
        -- login failed, attempt to rejoin a started game
    do
        print ("Rejoining...%N")
        server.rejoin (options.string_options @ "name",
                       options.string_options @ "password")
        from until server.has_joined or not server.is_joining loop
            server.get_data (-1)
        end
        if not server.has_joined then
            print ("Can't rejoin: ")
            print (join_reject_causes @ server.join_reject_cause)
            print ("%N")
        else
            print ("Rejoined%N")
        end
    end

    setup is
        -- Last stage on connection. Setup of player parameters (color, race, 
        -- etc.) and start of game
    require
        must_have_joined: server.has_joined
    local
        race: RACE
    do
        print ("Starting game...%N")
        create race.make
        race.set_homeworld_name ("Never Never Land")
        race.set_name (options.string_options @ "racename")
        race.set_picture (options.int_options @ "racepicture")
        server.set_ready(options.string_options @ "rulername",
            race,
            options.enum_options @ "color")
        print ("Waiting for other players...%N")
        from until
            server.game_status.started
        loop server.get_data (-1) end
    end

    play is
    do
        print ("Subscribing for game services%N")
        server.subscribe_init
        server.dialogs.on_dialog_addition.connect (agent new_dialog)
        print ("Playing now%N")
        from until False loop
            server.get_data (-1)
            if server.player.state = st_playing_turn then
                print ("Moving fleets%N")
                move_some_fleets
                print ("Ending the turn%N")
                server.end_turn (False)
            end
        end
    end

    cleanup is
    do
        if server /= Void and then not server.is_closed then
            server.close
        end
    end

    join_reject_causes: ARRAY [STRING] is
    once
        !!Result.make (reject_cause_duplicate, max_reject_cause)
        Result.put (l("Another player with that name is playing"), reject_cause_duplicate)
        Result.put (l("Invalid Password"), reject_cause_password)
        Result.put (l("No room for more players"), reject_cause_noslots)
        Result.put (l("Game has finished"), reject_cause_finished)
        Result.put (l("Access denied"), reject_cause_denied)
        Result.put (l("You are already logged in"), reject_cause_relog)
        Result.put (l("That player is already logged in"), reject_cause_alreadylog)
    end

feature -- Incredibly smart AI

    move_some_fleets is
    local
        i: ITERATOR [FLEET]
        j: ITERATOR [SHIP]
        s: ITERATOR [STAR]
        ll: HASHED_SET [SHIP]
    do
        from
            i := server.galaxy.get_new_iterator_on_fleets
        until i.is_off loop
            if i.item.owner = server.player and i.item.destination = Void then
                !!ll.make
                from j := i.item.get_new_iterator until j.is_off loop
                    ll.add (j.item)
                    j.next
                end
                if not ll.is_empty then
                    from                    
                        s := server.galaxy.get_new_iterator_on_stars
                    until 
                        s.is_off or else
                            (server.player.fuel_range > s.item |-| i.item.orbit_center and
                             s.item /= i.item.orbit_center)
                    loop
                        s.next
                    end
                    if not s.is_off then
                        server.move_fleet (i.item, s.item, ll)
                    end
                else
                    print ("Fleet empty? ")
                    print (i.item.id.to_string)
                    print ("<-id   ships->")
                    print (i.item.ship_count.to_string)
                    print ("%N")
                end
            end
            i.next
        end
    end

--Duplicated code with MAIN_WINDOW. refactor

    new_dialog (args: TUPLE[INTEGER, INTEGER, STRING]) is
    local
        id, kind: INTEGER
        dinfo: STRING
    do
        id := args.first
        kind := args.second
        dinfo := args.third
        inspect kind
        when dk_colonization then
            on_colonize_dialog (id, dinfo)
        when dk_engage then
            on_engage_dialog (id, dinfo)
        else
            print ("Unrecognized dialog kind%N")
        end
    end

    on_colonize_dialog (id: INTEGER; dinfo: STRING) is
    local
        s: SERIALIZER2
    do
        create s.make
        s.add_integer (0) -- Do not colonize
        server.dialog (id, s.serialized_form)
    end

    on_engage_dialog (id: INTEGER; dinfo: STRING) is
    local
        s: SERIALIZER2
    do
        create s.make
        s.add_integer (0) 
        s.add_integer (0) -- Do not engage
        server.dialog (id, s.serialized_form)
    end
    
end -- class DUMB_CLIENT
