class SETUP_WINDOW

inherit
    VEGTK_MAIN
    CLIENT
    GETTEXT
    STRING_FORMATTER
    SETUP_WINDOW_GUI
    PLAYER_CONSTANTS

creation
    make

feature -- Operations

    activate is
    require
        server /= Void and not server.is_closed
        server.player_name /= Void
        server.player /= Void
    do
        setup_window.set_title (format(l("Player setup for ~1~"),
                                     <<server.player_name>>))
        options_frame.set_label (server.player_name)
        color_menu.set_history (server.player.color_id)
        setup_window.show_all
        !!idle_network.make (Current, $on_idle_network, Void)
    end

feature -- Access

    flag_viewer: FLAG_VIEW

feature {NONE} -- Callbacks

    idle_network: GTK_IDLE
        -- Idle function that gets data from network

    customize_race (data: ANY; cb_data: VEGTK_CALLBACK_DATA) is
    do
        print ("Not implemented%N")
    end

    start_game (data: ANY; cb_data: VEGTK_CALLBACK_DATA) is
    do
        server.set_ready
    end

    retire_from_game (data: ANY; cb_data: VEGTK_CALLBACK_DATA) is
    do
        print ("Not implemented%N")
    end

    disconnect (data: ANY; cb_data: VEGTK_CALLBACK_DATA) is
    do
        server.close
        destroy
    end

    delete_event (data: ANY; cb_data: VEGTK_CALLBACK_DATA) is
        -- When the window is closed from the WM
    do
        -- This is to avoid window from getting destroyed
        cb_data.set_return_value_boolean (True)
        destroy
    end

    destroy is
        -- Close and hide window
    do
        setup_window.hide
        flag_viewer.widget.hide
        idle_network.remove
        gtk_main_quit
    end

    on_idle_network is
        -- Get data from network, updating local info
    do
        if not server.is_closed and server.is_joined and
           not server.game_status.started then
            server.get_data (network_wait)
        else -- Connection lost or player ready
            destroy
        end
    end

feature {NONE} -- Custom widgets

    new_custom_flag_view: GTK_WIDGET is
    do
        !!flag_viewer.make (server.player_list)
        Result := flag_viewer.widget
    end

    new_custom_player_list_widget: GTK_WIDGET is
    local
        player_list: PLAYER_LIST_VIEW
    do
        !!player_list.make (server.player_list)
        Result := player_list.widget
    end

    new_custom_chat: GTK_WIDGET is
    do
        print ("Not implemented%N")
        !GTK_LABEL!Result.make ("chat")
    end

end -- class SETUP_WINDOW