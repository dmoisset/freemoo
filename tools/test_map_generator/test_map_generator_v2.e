class TEST_MAP_GENERATOR_V2

inherit
    DIRECT_SERVICE_PROVIDER
        rename make as dsp_make
    MAP_CONSTANTS
    PKG_USER
    STRING_FORMATTER
    EASY_CLIENT

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
        it: ITERATOR[S_STAR]
        cstar: C_STAR
        font: FONT
        colony: COLONY
        fleet: FLEET
        ship: SHIP
        trout_connection: EASY_FM_CLIENT_CONNECTION
    do
        -- Setup Service Registry
        dsp_make

        -- Setup package System
        pkg_system.make_with_config_file ("freemoo.conf")

        -- Generate Galaxy
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

        -- Setup Display
        !!d.make (640, 480, 16, False)
        !!c.make (create {IMAGE_FMI}.make_from_file("client/gui/default_cursor.fmi"), 6, 4)
        d.root.set_pointer (c)
        !BITMAP_FONT_FMI!font.make("client/gui/default_font.fmi")
        d.set_default_font(font)



        -- Setup Services
        !!cgalaxy.make
        register(sgalaxy, "galaxy")
        subscribe(cgalaxy, "galaxy")
        !!view.make(d.root, d.root.location, cgalaxy)
        sgalaxy.update_clients
        from
            i := 1
            it := sgalaxy.stars.get_new_iterator_on_items
        until i > 40 loop
            if it.item.kind /= kind_blackhole then
                register (it.item, "star" + it.item.id.to_string)
                cstar ?= cgalaxy.stars @ it.item.id
                subscribe (cstar, "star" + it.item.id.to_string)
                it.item.update_clients
            end
            it.next
            i := i + 1
        end

        !!trout_connection.easy_make(plist, cgalaxy, plist @ "Hugo")
        easy_set_server(trout_connection)

        from it := sgalaxy.stars.get_new_iterator_on_items
        until (it.item.planets @ 3) /= Void and then (it.item.planets @ 3).type = type_planet
        loop it.next end
        cstar := cgalaxy.stars @ it.item.id
        !!colony.make(it.item.planets @ 3, plist @ "Hugo")
        !!colony.make(cstar.planets @ 3, plist @ "Hugo")
        !!fleet.make
        fleet.set_owner(plist @ "Hugo")
        fleet.enter_orbit (cstar)
        !!ship.make
        fleet.add_ship(ship)
        sgalaxy.fleets.add(fleet, fleet.id)
        sgalaxy.generate_scans(plist)
        register(sgalaxy, (plist @ "Hugo").id.to_string + ":scanner")
        subscribe(cgalaxy, (plist @ "Hugo").id.to_string + ":scanner")

        -- Main loop
        d.set_timer_interval (40)
        d.do_event_loop
        d.close
    end -- make


feature {NONE}

    sgalaxy: S_GALAXY
    cgalaxy: C_GALAXY

end -- class TEST_MAP_GENERATOR_V2
