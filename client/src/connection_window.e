class CONNECTION_WINDOW
    -- Window for connecting to a server

inherit
    VEGTK_MAIN
    CONNECT_WINDOW_GUI
    redefine make end
    GETTEXT
    CLIENT

creation
    make

feature {NONE} -- Creation

    make is
    do
        Precursor
        set_state (st_disconnected)
    end

feature -- Operations

    activate is
        -- Show
    require
        server = Void or else server.is_closed
    do
        if server /= Void then
            status_label.set_text (l("Connection to server lost."))
        end
        connect_button.grab_default
        host_entry.grab_focus
        connect_window.show_all
        set_state (st_disconnected)
    end

feature {NONE} -- Callbacks

    idle_network: GTK_IDLE
        -- Idle function that gets data from network

    delete_event (data: ANY; cb_data: VEGTK_CALLBACK_DATA) is
        -- When the window is closed from the WM
    do
        -- This is to avoid window from getting destroyed
        cb_data.set_return_value_boolean (True)
        destroy (data, cb_data)
    end

    destroy (data: ANY; cb_data: VEGTK_CALLBACK_DATA) is
        -- Close and hide window
    do
        if state=st_waiting_info then
            server.close
        end
        connect_window.hide
        gtk_main_quit
    end

    connect (data: ANY; cb_data: VEGTK_CALLBACK_DATA) is
        -- Connect button was clicked
    local
        port_num: INTEGER
        dummy: BOOLEAN
    do
        set_state (st_connecting)
        if not port_entry.get_text.is_integer then
            status_label.set_text (l("Invalid port number."))
            set_state (st_disconnected)
        else
            status_label.set_text (l("Looking up host..."))
            from until gtk_events_pending=0 loop
                dummy := gtk_main_iteration
            end
            port_num := port_entry.get_text.to_integer
            set_server (host_entry.get_text, port_num)
            if server.is_opening then
                status_label.set_text (l("Connecting..."))
                !!idle_network.make (Current, $on_idle_network, Void)
            else
                status_label.set_text (l("Can't connect."))
                set_state (st_disconnected)
            end
        end
    end

    on_idle_network is
        -- wait for network data, update info and move progress indicator.
    do
        inspect
            state
        when st_connecting then
            if server.is_opening then
                if tolerant_wait_connection then
                    do_nothing
                end
                status_bar.set_value (1-status_bar.get_value)
            elseif server.is_closed then
                set_state (st_disconnected)
                status_label.set_text (l("Connection failed."))
            else
                set_state (st_waiting_info)
            end
        when st_waiting_info then
            server.get_data (network_wait)
            status_bar.set_value (1-status_bar.get_value)
            if server.has ("game_status") and
               server.has ("players_list") then
                set_state (st_connected)
                server.subscribe_base
            end
            if server.is_closed then
                set_state (st_disconnected)
                status_label.set_text (l("Connection failed."))
            end
        when st_disconnected then
            idle_network.remove
            idle_network := Void
        when st_connected then
            idle_network.remove
            idle_network := Void
        end
    end

feature {NONE} -- Internal

    state: INTEGER
         -- State of the connection, valid after asking connection

    st_disconnected,
    st_connecting,
    st_waiting_info,
    st_connected: INTEGER is unique
        -- Constants for `state'

    set_state (value: INTEGER) is
        -- Change `state'
    require
        value.in_range (st_disconnected, st_connected)
    do
        state := value
        inspect state
        when st_disconnected then
            connect_button.set_sensitive (True)
            status_bar.hide
        when st_connecting then
            connect_button.set_sensitive (False)
            status_bar.show
            status_bar.set_value (0)
        when st_waiting_info then
            status_label.set_text (l("Waiting for server data..."))
        when st_connected then
            connect_button.set_sensitive (False)
            connect_window.hide
            gtk_main_quit
        end
    end

    tolerant_wait_connection: BOOLEAN is
        -- Wait some short time for connection, return True if still connecting.
    do
        if not Result then
            server.wait_connection (network_wait)
        end
    rescue
        Result := True
        retry
    end

invariant
    state.in_range (st_disconnected, st_connected)

end -- class CONNECTION_WINDOW