deferred class CONNECT_WINDOW_GUI

inherit
    WINDOW
    redefine make, focusable end

feature {NONE} -- Creation

    make (w: WINDOW; where: RECTANGLE) is
        -- Build GUI
    local
        background: WINDOW_ANIMATED
        r: RECTANGLE
    do
        Precursor (w, where)
-- get image from the package
        !!background.make (Current, 0, 0, create {ANIMATION_SEQUENTIAL}.make (
            <<create {SDL_IMAGE}.make_from_file ("../data/client/connect-window/background.png")>>
        ))

        -- Make entries
-- take coordinates form data file
        r.set_with_size (268, 182, 150, 21)
        !!host_entry.make (Current, r)
        host_entry.set_text ("localhost")

        r.set_with_size (268, 207, 150, 21)
        !!port_entry.make (Current, r)
        port_entry.set_text ("3002")

        -- Make buttons
        !BUTTON_IMAGE!connect_button.make (Current, 220, 250,
            create {SDL_IMAGE}.make_from_file ("../data/client/connect-window/connect-button-u.png"),
            create {SDL_IMAGE}.make_from_file ("../data/client/connect-window/connect-button-p.png"),
            create {SDL_IMAGE}.make_from_file ("../data/client/connect-window/connect-button-d.png")
            )
        connect_button.set_click_handler (agent connect)

        !BUTTON_IMAGE!quit_button.make (Current, 330, 250,
            create {SDL_IMAGE}.make_from_file ("../data/client/connect-window/connect-button-u.png"),
            create {SDL_IMAGE}.make_from_file ("../data/client/connect-window/connect-button-p.png"),
            create {SDL_IMAGE}.make_from_file ("../data/client/connect-window/connect-button-d.png")
            )
        quit_button.set_click_handler (agent quit)

        r.set_with_size (48, 350, 300, 25)
        !!status_label.make(Current, r,
                            l("Please, enter server address and port."))

        r.set_with_size (48, 375, 150, 25)
        !!status_bar.make (Current, r)

        hide
    end

feature -- Redefined features

    focusable: BOOLEAN is True

feature {NONE} -- Widgets

    port_entry: TEXT_ENTRY
    host_entry: TEXT_ENTRY
    status_label: LABEL
    status_bar: CONNECTION_INDICATOR
    connect_button: BUTTON
    quit_button: BUTTON

feature {NONE} -- Callbacks

    connect is
    deferred end

    quit is
    deferred end

    delete_event is
    deferred end

end -- class CONNECT_WINDOW_GUI
