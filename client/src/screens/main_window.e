class MAIN_WINDOW
    -- Main game window

inherit
    MAIN_WINDOW_GUI
    redefine
        handle_event
    end
    GETTEXT
    CLIENT
    PLAYER_CONSTANTS

creation
    make

feature -- Redefined_features

    handle_event (event: EVENT) is
    local
        s: EVENT_SDL_CUSTOM
        n: EVENT_NETWORK
    do
        s ?= event
        if s /= Void and then s.sdl_event.type=sdl_network_event then
            on_network_data
            event.set_handled
        end
        Precursor (event)
        n ?= event
        if n /= Void then
            on_network_event
        end
    end

feature {NONE} -- Callbacks

    sdl_network_event: INTEGER is 25

    on_network_data is
    do
        -- Move bits
        if server /= Void and then not server.is_closed then
            server.get_data (-1)
            netevent_ack
        end
    end

    on_network_event is
    do
        inspect state
        when st_offline then
            if not connection_window.visible then
                connection_window.activate
            end
        when st_connected then
            if not join_window.visible then
                join_window.activate
            end
        when st_joined then
            if not setup_window.visible then
                 setup_window.activate
            end
        else
        end
    end

feature -- Operations

    activate is
    require
        server = Void
    do
        show
        on_network_event
    end

feature {NONE} -- Internal

    state: INTEGER is
    do
        if server = Void or else server.is_closed or else
               not server.has ("game_status") or else
               not server.has ("players_list") then
            Result := st_offline
        elseif not server.is_joined then
            Result := st_connected
        elseif not server.game_status.started then
            Result := st_joined
        else
            Result := st_playing
        end
    end

    st_offline, st_connected, st_joined,
    st_playing: INTEGER is unique

feature {NONE} -- Dialogs 

    connection_window: CONNECTION_WINDOW is
    once
        !!Result.make (display.root, display.dimensions)
        Result.hide
    end

    join_window: JOIN_WINDOW is
    once
        !!Result.make (display.root, display.dimensions)
        Result.hide
    end

    setup_window: SETUP_WINDOW is
    once
        !!Result.make (display.root, display.dimensions)
        Result.hide
    end

feature {NONE} -- External

    netevent_ack is
    external "C"
    end

end -- class MAIN_WINDOW