class FM_CLIENT
    -- FreeMOO client

inherit
    CLIENT
    PKG_USER

creation make

feature {NONE} -- Creation

    make is
    local
        sdl: SDL
    do
        pkg_system.make_with_config_file ("freemoo.conf")
        -- Initialize display
        !!display.make (640, 480, 16, False)
        display.set_timer_interval (40)
        sdl.enable_keyboard_repeat (250, 50)
-- Load font form package, fonts should be shared
        display.set_default_font (create {SDL_BITMAP_FONT}.make
            ("../data/client/gui/default_font.png"))

        display.root.set_pointer (create {MOUSE_POINTER}.make (
            create {IMAGE_FMI}.make_from_file ("client/gui/default_cursor.fmi"),
            6, 4))

        !!connection_window.make (display.root, display.dimensions)
        -- Enter the event loop
        display.do_event_loop
        cleanup
--    rescue
--        cleanup
    end

    cleanup is
    do
        if server /= Void and then not server.is_closed then
            server.close
        end
        if display /= Void then
            display.close
        end
    end

feature {NONE} -- Windows

    display: SDL_DISPLAY

    connection_window: CONNECTION_WINDOW

end -- class FM_CLIENT