class JOIN_WINDOW
    -- Window for joining to te game

inherit
    VEGTK_MAIN
    JOIN_WINDOW_GUI
    GETTEXT
    CLIENT
    STRING_FORMATTER
    PROTOCOL

creation
    make

feature -- Operations

    activate is
        -- Show window
    require
        server /= Void
        not server.is_closed
        not server.is_joining
        not server.is_joined
    do
        join_window.set_title (format(l("Connected to ~1~:~2~"),
                                     <<server.dq_address, server.port>>))
        status_label.set_text (
            l("Join as new player or rejoin as existing one."))
        name.grab_focus
        join_window.show_all
        bjoin.set_sensitive (True)
        joining := False
        !!idle_network.make (Current, $on_idle_network, Void)
    end

feature {NONE} -- Callbacks

    idle_network: GTK_IDLE
        -- Idle function that gets data from network

    delete_event (data: ANY; cb_data: VEGTK_CALLBACK_DATA) is
        -- Called when the window is closed from the WM
    do
        -- This is to avoid window from getting destroyed
        cb_data.set_return_value_boolean (True)
        destroy
    end

    destroy is
        -- Close and hide window
    do
        join_window.hide
        idle_network.remove
        gtk_main_quit
    end

    join (data: ANY; cb_data: VEGTK_CALLBACK_DATA) is
        -- Join button clicked
    do
        rejoin := server.player_list.has (name.get_text)
        if rejoin then
            server.rejoin (name.get_text, password.get_text)
        else
            server.join (name.get_text, password.get_text)
        end
        joining := True
        bjoin.set_sensitive (False)
    end

    disconnect (data: ANY; cb_data: VEGTK_CALLBACK_DATA) is
        -- Disconnect button clicked
    do
        server.close
        destroy
    end

    on_idle_network is
        -- Get data from network, updating local info
    do
        if not server.is_closed then
            server.get_data (network_wait)
            if server.is_joined then
                destroy
            end
            if joining and not server.is_joining then
                joining := False
                bjoin.set_sensitive (True)
                if rejoin then
                    status_label.set_text(
                        format (l("Can't rejoin: ~1~"), <<
                        rejoin_reject_causes @ server.join_reject_cause>>)
                    )
                else
                    status_label.set_text(
                        format (l("Can't join: ~1~"), <<
                        join_reject_causes @ server.join_reject_cause>>)
                    )
                end
            end
        else -- Connection lost
            destroy
        end
    end

feature {NONE} -- Internal

    joining: BOOLEAN
        -- True when the Join button until the server accepts or
        -- rejects the join.

    rejoin: BOOLEAN
        -- The last operation was a rejoin

feature {NONE} -- Constants

    new_custom_player_list_widget: GTK_WIDGET is
    local
        player_list: PLAYER_LIST_VIEW
    do
        !!player_list.make (server.player_list)
        Result := player_list.widget
    end

    new_custom_server_rules: GTK_WIDGET is
    local
        status: GAME_STATUS_VIEW
    do
        !!status.make (server.game_status)
        Result := status.widget
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

    rejoin_reject_causes: ARRAY [STRING] is
    once
        !!Result.make (reject_cause_duplicate, reject_cause_last)
        Result.put (l("That player is not playing"), reject_cause_duplicate)
        Result.put (l("Invalid password"), reject_cause_password)
        Result.put (l("Game has finished"), reject_cause_finished)
        Result.put (l("Access denied"), reject_cause_denied)
        Result.put (l("You are already logged in"), reject_cause_relog)
        Result.put (l("That player is already logged in"), reject_cause_alreadylog)
    end

end -- class JOIN_WINDOW