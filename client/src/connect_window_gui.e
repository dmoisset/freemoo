deferred class CONNECT_WINDOW_GUI

inherit
    WINDOW
    redefine make end
    GETTEXT

feature {NONE} -- Creation

    make (w: WINDOW; where: RECTANGLE) is
        -- Build GUI
    local
        r: RECTANGLE
        b: WINDOW_IMAGE
        a: FMA_FRAMESET
    do
        Precursor (w, where)
        !!a.make ("client/connect-window/background.fma")
        !!background.make (Current, 0, 0, a.images @ 1)
        !!b.make (background, 0, 0,
            create {IMAGE_FMI}.make_from_file ("client/connect-window/background.fmi")
        )

        -- Make entries
-- take coordinates form data file
        r.set_with_size (268, 182, 150, 21)
        !!host_entry.make (background, r)
        host_entry.set_text ("localhost")

        r.set_with_size (268, 207, 150, 21)
        !!port_entry.make (background, r)
        port_entry.set_text ("3002")

        host_entry.set_next_in_tab_order (port_entry)
        port_entry.set_next_in_tab_order (host_entry)

        -- Make buttons
        !BUTTON_IMAGE!connect_button.make (background, 220, 250,
            create {IMAGE_FMI}.make_from_file ("client/connect-window/connect-button-u.fmi"),
            create {IMAGE_FMI}.make_from_file ("client/connect-window/connect-button-p.fmi"),
            create {IMAGE_FMI}.make_from_file ("client/connect-window/connect-button-d.fmi")
            )
        connect_button.set_click_handler (agent connect)

        !BUTTON_IMAGE!quit_button.make (background, 330, 250,
            create {IMAGE_FMI}.make_from_file ("client/connect-window/connect-button-u.fmi"),
            create {IMAGE_FMI}.make_from_file ("client/connect-window/connect-button-p.fmi"),
            create {IMAGE_FMI}.make_from_file ("client/connect-window/connect-button-d.fmi")
            )
        quit_button.set_click_handler (agent quit)

        r.set_with_size (48, 350, 300, 25)
        !!status_label.make(background, r,
                            l("Please, enter server address and port."))

        r.set_with_size (48, 375, 150, 25)
        !!status_bar.make (background, r)
    end

feature {NONE} -- Widgets

    background: WINDOW_IMAGE
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
