class MAIN_WINDOW
    -- Main game window

inherit
    VEGTK_MAIN
    VEGTK_HELPER
    GETTEXT
    CLIENT
    PLAYER_CONSTANTS

creation
    make

feature {NONE} -- Creation

    make is
    do
        !!window.make (Gtk_window_dialog)
        signal_connect (window, "delete-event", $delete_event)
        !!idle_network.make (Current, $on_idle_network, Void)
    end

feature -- Operations

    activate is
    do
        window.add (new_button ("H_ello", $destroy))
        window.show_all
    end

feature {NONE} -- Callbacks

    idle_network: GTK_IDLE

    delete_event (data: ANY; cb_data: VEGTK_CALLBACK_DATA) is
    do
        -- This is to avoid window from getting destroyed
        cb_data.set_return_value_boolean (True)
        destroy
    end

    destroy is
    do
        gtk_main_quit
    end

    on_idle_network is
    do
        -- Ask server if disconnected
        if server = Void or else server.is_closed then
            connection_window.activate
            gtk_main
        end
        -- Ask login if not logged
        if server = Void or else server.is_closed then
            destroy
        elseif not server.is_joined then
            join_window.activate
            gtk_main
        end
        -- Setup if not ready
        if server /= Void and then
           server.is_joined and then not server.game_status.started then
            setup_window.activate
            gtk_main
        end
        -- Move bits
        if server /= Void and then not server.is_closed then
            server.get_data (network_wait)
        end
    end

feature -- Access

    window: GTK_WINDOW

feature {NONE} -- Dialogs 

    connection_window: CONNECTION_WINDOW is
    once
        !!Result.make
    end

    join_window: JOIN_WINDOW is
    once
        !!Result.make
    end

    setup_window: SETUP_WINDOW is
    once
        !!Result.make
    end

end -- class MAIN_WINDOW