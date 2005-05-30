deferred class JOIN_WINDOW_GUI

inherit
    WINDOW
    redefine make end

feature {NONE} -- Creation

    make (w: WINDOW; where: RECTANGLE) is
        -- Build GUI
    local
        a: FMA_FRAMESET
        background: WINDOW_IMAGE
        r: RECTANGLE
    do
        Precursor (w, where)

        !!a.make ("client/connect-window/background.fma")
        !!background.make (Current, 0, 0, a.images @ 1)
        !!background.make (Current, 0, 0,
            create {IMAGE_FMI}.make_from_file ("client/join-window/background.fmi")
        )

        r.set_with_size (75, 75, 150, 25)
        !!title_label.make (Current, r, "Connected to ~1~")
        title_label.set_h_alignment (0)

        r.set_with_size (75, 100, 235, 175)
        new_player_list (r)

        r.set_with_size (330, 100, 235, 175)
        new_server_rules (r)

        r.set_with_size (297, 307, 125, 20)
        !!name.make (Current, r)

        r.set_with_size (297, 332, 125, 20)
        !!password.make (Current, r)
        password.enable_text_hiding
        
        name.set_next_in_tab_order (password)
        password.set_next_in_tab_order (name)

        r.set_with_size (120, 350, 400, 25)
        !!status_label.make (Current, r, "Join as new player or rejoin as existing one.")

        !BUTTON_IMAGE!join_button.make (Current, 220, 375,
            create {IMAGE_FMI}.make_from_file ("client/connect-window/connect-button-u.fmi"),
            create {IMAGE_FMI}.make_from_file ("client/connect-window/connect-button-p.fmi"),
            create {IMAGE_FMI}.make_from_file ("client/connect-window/connect-button-d.fmi")
            )
        join_button.set_click_handler (agent join)

        !BUTTON_IMAGE!disconnect_button.make (Current, 330, 375,
            create {IMAGE_FMI}.make_from_file ("client/connect-window/connect-button-u.fmi"),
            create {IMAGE_FMI}.make_from_file ("client/connect-window/connect-button-p.fmi"),
            create {IMAGE_FMI}.make_from_file ("client/connect-window/connect-button-d.fmi")
            )
        disconnect_button.set_click_handler (agent disconnect)

        hide
    end

feature {NONE} -- Widgets

    title_label: LABEL
    name, password: TEXT_ENTRY
    player_list: PLAYER_LIST_VIEW
    server_rules: GAME_STATUS_VIEW
    status_label: LABEL
    join_button, disconnect_button: BUTTON

    new_player_list (where: RECTANGLE) is
    deferred
    end

    new_server_rules (where: RECTANGLE) is
    deferred
    end

feature {NONE} -- Callbacks

    join is
    deferred end

    disconnect is
    deferred end

    delete_event is
    deferred end

end -- class JOIN_WINDOW_GUI
