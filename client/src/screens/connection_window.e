class CONNECTION_WINDOW
    -- Window for connecting to a server

inherit
    CONNECT_WINDOW_GUI
    redefine
        make,
        handle_event
    end
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
        s: EVENT_SDL_CUSTOM
    do
        s ?= event
        if s /= Void and then s.sdl_event.type=sdl_network_event then
            on_network_data
            event.set_handled
        end
        Precursor (event)
        t ?= event
        if t /= Void and state=st_connecting then
            on_timer
        end
        n ?= event
        if n /= Void then
            on_network
        end
    end

feature {NONE} -- Callbacks

    sdl_network_event: INTEGER is 25

    quit is
    do
        destroy
        display.add_event (create {EVENT_QUIT})
    end

    destroy is
        -- Close window
    do
        if server/=Void and then not server.is_closed then
            server.close
            set_state (st_disconnected)
        end
    end

    connect is
        -- Connect button was clicked
    require
        state = st_disconnected
    local
        port_num: INTEGER
        f: CONNECTION_FACTORY
    do
        if not port_entry.text.is_integer then
            status_label.set_text (l("Invalid port number."))
        else
            status_label.set_text (l("Looking up host..."))
            -- We're about to block for a while during name lookup
            -- So we'd better update the screen
            display.redraw
            port_num := port_entry.text.to_integer
            !FM_SDL_CLIENT_CONNECTION_FACTORY!f.make (display)
            set_server (host_entry.text, port_num, f)
            if server /= Void and then server.is_opening then
                set_state (st_connecting)
            else
                status_label.set_text (l("Can't connect."))
            end
        end
    end

    on_timer is
        -- wait for network data, update info and move progress indicator.
    require
        state = st_connecting
    local
        dummy: BOOLEAN
    do
        if server.is_opening then
            dummy := tolerant_wait_connection
            if not server.is_opening and not server.is_closed then
                set_state (st_waiting_info)
            end
        elseif server.is_closed then
            set_state (st_disconnected)
            status_label.set_text (l("Connection failed."))
        end
    end

    on_network is
    do
        inspect
            state
        when st_waiting_info then
            if server.has ("game_status") and
               server.has ("players_list") then
                set_state (st_joining)
            end
        when st_joining then
            if server.has_joined then
                if server.game_status.started then
                    set_state (st_playing)
                else
                    set_state (st_preparing)
                end
            end
        when st_preparing then
            if server.game_status.started then
                set_state (st_playing)
            end
        when st_playing then
            if server.game_status.finished then
                set_state (st_finish)
            end
        when st_finish then
        end
        if server.is_closed then
            set_state (st_disconnected)
            status_label.set_text (l("Connection failed."))
        end
    end

    on_network_data is
    do
        -- Move bits
        if server /= Void and then not server.is_closed then
            server.get_data (-1)
            netevent_ack
        end
    end

feature {NONE} -- Internal

    state: INTEGER
         -- State of the connection, valid after asking connection

    st_disconnected,
    st_connecting,
    st_waiting_info,
    st_joining,
    st_preparing,
    st_playing,
    st_finish: INTEGER is unique
        -- Constants for `state'

    set_state (value: INTEGER) is
        -- Change `state'
    require
        value.in_range (st_disconnected, st_finish)
    do
        state := value
        inspect state
        when st_disconnected then
            background.show
            if server /= Void then
                status_label.set_text (l("Connection to server lost."))
                safe_hide (setup_window)
                safe_hide (join_window)
                safe_hide (main_window)
            end
            connect_button.show
            status_bar.deactivate
            host_entry.grab
        when st_connecting then
            connect_button.hide
            status_bar.activate
            status_label.set_text (l("Connecting..."))
        when st_waiting_info then
            status_label.set_text (l("Waiting for server data..."))
        when st_joining then
            server.subscribe_base
            if join_window=Void then
                !!join_window.make (Current, display.dimensions)
            end
            background.hide
            join_window.activate
        when st_preparing then
            safe_hide(join_window)
            if setup_window=Void then
                !!setup_window.make (Current, display.dimensions)
            end
            setup_window.activate
        when st_playing then
            safe_hide (setup_window)
            server.subscribe_init
            if main_window=Void then
                !!main_window.make (Current, display.dimensions)
            end
            main_window.activate
        when st_finish then
            safe_hide (main_window)
                check end_window = Void end
            !!end_window.make (Current, display.dimensions)
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

feature {NONE} -- Dialogs 

    join_window: JOIN_WINDOW

    setup_window: SETUP_WINDOW

    main_window: MAIN_WINDOW

    end_window: END_WINDOW
    
    safe_hide (w: WINDOW) is
        -- Hide `w' if `w' is not Void
    do
        if w /= Void then
            w.hide
        end
    end

feature {NONE} -- External

    netevent_ack is
    external "C"
    end

invariant
    state.in_range (st_disconnected, st_finish)

end -- class CONNECTION_WINDOW