class CONNECTION_WINDOW
    -- Window for connecting to a server

inherit
    CONNECT_WINDOW_GUI
    redefine
        make,
        handle_event
    end
    GETTEXT
    CLIENT

creation
    make

feature {NONE} -- Creation

    make (w: WINDOW; where: RECTANGLE) is
    do
        state := st_disconnected
        Precursor (w, where)
        set_state (st_disconnected)
    end

feature -- Redefined features

    handle_event (event:EVENT) is
    local
        t: EVENT_TIMER
        n: EVENT_NETWORK
    do
        Precursor (event)
        t ?= event
        if t /= Void and on_timer_enabled then
            on_timer
        end
        n ?= event
        if n /= Void then
            on_network
        end
    end

feature -- Operations

    activate is
        -- Show
    require
        server = Void or else server.is_closed
    do
        show
        if server /= Void then
            status_label.set_text (l("Connection to server lost."))
        end
        host_entry.grab
        set_state (st_disconnected)
    end

feature {NONE} -- Callbacks

    destroy is
        -- Close and hide window
    do
        if state=st_waiting_info then
            server.close
            set_state (st_disconnected)
        end
        hide
    end

    quit is
    do
        destroy
        display.add_event (create {EVENT_QUIT})
    end

    connect is
        -- Connect button was clicked
    local
        port_num: INTEGER
        f: CONNECTION_FACTORY
    do
        set_state (st_connecting)
        if not port_entry.text.is_integer then
            status_label.set_text (l("Invalid port number."))
            set_state (st_disconnected)
        else
            status_label.set_text (l("Looking up host..."))
            -- We're about to block for a while during name lookup
            -- So we'd better update the screen
            display.redraw
            port_num := port_entry.text.to_integer
            !FM_SDL_CLIENT_CONNECTION_FACTORY!f.make (display)
            set_server (host_entry.text, port_num, f)
            if server /= Void and then server.is_opening then
                status_label.set_text (l("Connecting..."))
                on_timer_enabled := True
            else
                status_label.set_text (l("Can't connect."))
                set_state (st_disconnected)
            end
        end
    end

    on_timer_enabled: BOOLEAN

    on_timer is
        -- wait for network data, update info and move progress indicator.
    require
        state = st_connecting
    do
        if server.is_opening then
            if tolerant_wait_connection then
                do_nothing
            end
        elseif server.is_closed then
            set_state (st_disconnected)
            on_timer_enabled := False
            status_label.set_text (l("Connection failed."))
        end
    end

    on_network is
    do
        on_timer_enabled := False
        inspect
            state
        when st_connecting then
            set_state (st_waiting_info)
        when st_waiting_info then
            if server.has ("game_status") and
               server.has ("players_list") then
                set_state (st_connected)
                server.subscribe_base
            end
            if server.is_closed then
                set_state (st_disconnected)
                status_label.set_text (l("Connection failed."))
            end
        else
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
            connect_button.show
            status_bar.deactivate
        when st_connecting then
            connect_button.hide
            status_bar.activate
        when st_waiting_info then
            status_label.set_text (l("Waiting for server data..."))
        when st_connected then
            connect_button.hide
            status_bar.deactivate
            destroy
        end
    end

    tolerant_wait_connection: BOOLEAN is
        -- Wait some short time for connection, return True if still connecting.
    do
        if not Result then
            server.wait_connection (0)
        end
    rescue
        Result := True
        retry
    end

invariant
    state.in_range (st_disconnected, st_connected)

end -- class CONNECTION_WINDOW