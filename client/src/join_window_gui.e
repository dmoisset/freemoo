deferred class JOIN_WINDOW_GUI

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
            <<create {SDL_IMAGE}.make_from_file ("../data/client/join-window/background.png")>>
        ))

        r.set_with_size (48, 48, 150, 25)
        !!title_label.make (Current, r, "Connected to ~1~")
        title_label.set_alignment (0, 0.5)

        r.set_with_size (48, 73, 262, 202)
        new_player_list (r)

        r.set_with_size (297, 307, 125, 20)
        !!name.make (Current, r)

        r.set_with_size (297, 332, 125, 20)
        !!password.make (Current, r)
        password.enable_text_hiding

        r.set_with_size (330, 73, 262, 202)
        new_server_rules (r)

        r.set_with_size (120, 350, 400, 25)
        !!status_label.make (Current, r, "Join as new player or rejoin as existing one.")

        !BUTTON_IMAGE!join_button.make (Current, 220, 375,
            create {SDL_IMAGE}.make_from_file ("../data/client/connect-window/connect-button-u.png"),
            create {SDL_IMAGE}.make_from_file ("../data/client/connect-window/connect-button-p.png"),
            create {SDL_IMAGE}.make_from_file ("../data/client/connect-window/connect-button-d.png")
            )
        join_button.set_click_handler (agent join)

        !BUTTON_IMAGE!disconnect_button.make (Current, 330, 375,
            create {SDL_IMAGE}.make_from_file ("../data/client/connect-window/connect-button-u.png"),
            create {SDL_IMAGE}.make_from_file ("../data/client/connect-window/connect-button-p.png"),
            create {SDL_IMAGE}.make_from_file ("../data/client/connect-window/connect-button-d.png")
            )
        disconnect_button.set_click_handler (agent disconnect)

        hide
    end

feature -- Redefined features

    focusable: BOOLEAN is True

feature {NONE} -- Widgets

    title_label: LABEL
    name, password: TEXT_ENTRY
    player_list: PLAYER_LIST_VIEW
    server_rules: GAME_STATUS_VIEW
    status_label: LABEL
    join_button, disconnect_button: BUTTON

feature {NONE} -- Callbacks

    join is
    deferred end

    disconnect is
    deferred end

    delete_event is
    deferred end

    new_player_list (where: RECTANGLE) is
    deferred
    end

    new_server_rules (where: RECTANGLE) is
    deferred
    end

end -- class JOIN_WINDOW_GUI
