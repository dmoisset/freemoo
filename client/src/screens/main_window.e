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
        t: EVENT_TIMER
    do
        Precursor (event)
        s ?= event
        if s /= Void and then s.sdl_event.type=sdl_network_event then
            s.set_handled
            on_network_event
        end
        t ?= event
        if t /= Void and not at_on_timer then
            at_on_timer := True
            on_timer
            at_on_timer := False
        end
    end

feature {NONE} -- Callbacks

    sdl_network_event: INTEGER is 25

    on_network_event is
    do
        -- Move bits
        if server /= Void and then not server.is_closed then
            server.get_data (-1)
            netevent_ack
        end
    end

    at_on_timer: BOOLEAN

    on_timer is
    do
        -- Ask server if disconnected
        if server = Void or else server.is_closed then
            connection_window.activate
            display.do_event_loop
        end
        -- Ask login if not logged
        if server = Void or else server.is_closed then
            display.add_event (create {EVENT_QUIT})
        elseif not server.is_joined then
            join_window.activate
            display.do_event_loop
        end
        -- Setup if not ready
        if server /= Void and then
           server.is_joined and then not server.game_status.started then
            setup_window.activate
            display.do_event_loop
        end
    end

feature -- Operations

    activate is
    do
        show
    end

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