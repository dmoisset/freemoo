class FM_CLIENT
    -- FreeMOO client

inherit
    VEGTK_MAIN
    VEGTK_CALLBACK_HANDLER
    GTK_CONSTANTS
    CLIENT

creation make

feature {NONE} -- Creation

    make is
    do
        vegtk_init
        !!main_window.make
        main_window.activate
        -- Enter the event loop
        gtk_main
        cleanup
--    rescue
--        cleanup
    end

    cleanup is
    do
        if server /= Void and then not server.is_closed then
            server.close
        end
    end

feature {NONE} -- Windows

    main_window: MAIN_WINDOW

end -- class FM_CLIENT