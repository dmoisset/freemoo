class FM_SDL_CLIENT_CONNECTION

inherit
    FM_CLIENT_CONNECTION
    redefine
        on_create,
        on_close,
        on_new_data
    end

creation
    make

feature -- Access

    display: DISPLAY
        -- Display that receives events

feature -- Operations

    set_display (new_display: DISPLAY) is
    do
        display := new_display
    end

feature {NONE} -- Redefined features

    on_create is
    local
        dummy: INTEGER
    do
        Precursor
        dummy := init_netevent_thread (socketfd)
        display.add_event (create {EVENT_NETWORK})
    end

    on_close is
    local
        dummy: INTEGER
    do
        dummy := stop_netevent_thread
        Precursor
        display.add_event (create {EVENT_NETWORK})
    end

    on_new_data (start: INTEGER) is
    do
        Precursor (start)
        display.add_event (create {EVENT_NETWORK})
    end

feature {NONE} -- External

    init_netevent_thread (fd: INTEGER): INTEGER is
    external "C"
    ensure Result = 0
    end

    stop_netevent_thread: INTEGER is
    external "C"
    ensure Result = 0
    end

end