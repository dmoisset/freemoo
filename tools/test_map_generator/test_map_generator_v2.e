class TEST_MAP_GENERATOR_V2

inherit
    DIRECT_SERVICE_PROVIDER
        rename make as dsp_make
    MAP_CONSTANTS
    PKG_USER
    STRING_FORMATTER

creation {ANY}
    make

feature {ANY}

    make is
    local
        d: SDL_DISPLAY
        mapgen: MAP_GENERATOR
        options: SERVER_OPTIONS
        player: EASY_PLAYER
        plist: EASY_PLAYER_LIST
        view: GALAXY_VIEW
        c: MOUSE_POINTER
        i: INTEGER
    do
        dsp_make
        pkg_system.make_with_config_file ("freemoo.conf")

        !!options.make
        options.parse_add ("galaxysize = huge")
        options.parse_add ("galaxyage = average")
        from i := 1 until i > argument_count loop
            options.parse_add (argument (i))
            if options.status /= options.st_ok then
                std_error.put_string(
                    format (l("Invalid option: ~1~%N"), <<argument (i)>>)
                )
            end
            i := i + 1
        end
        !MAP_GENERATOR_FAST!mapgen.make (options)

        !!plist.make
        !!player.with_name ("Yo", 1)
        plist.add (player)
        !!player.with_name ("Hugo", 2)
        plist.add (player)
        !!player.with_name ("Paco", 3)
        plist.add (player)
        !!player.with_name ("Luis", 4)
        plist.add (player)
        !!player.with_name ("Pepe", 5)
        plist.add (player)
        !!player.with_name ("Huevo", 6)
        plist.add (player)
        !!player.with_name ("Totote", 7)
        plist.add (player)

        !!sgalaxy.make
        mapgen.generate (sgalaxy, plist)

        !!d.make (640, 480, 16, False)
        -- Set Pointer
        !!c.make (create {SDL_IMAGE}.make_from_file("../../data/client/gui/default_cursor.png"), 6, 4)
        d.root.set_pointer (c)
        !!cgalaxy.make

        register(sgalaxy, "galaxy")
        subscribe(cgalaxy, "galaxy")

        !!view.make(d.root, d.root.location, cgalaxy)
        sgalaxy.update_clients

        -- Main loop
        d.set_timer_interval (40)
        d.do_event_loop
        d.close
    end -- make


feature {NONE}

    sgalaxy: S_GALAXY
    cgalaxy: C_GALAXY

end -- class TEST_MAP_GENERATOR_V2
