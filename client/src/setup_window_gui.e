deferred class SETUP_WINDOW_GUI

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
            <<create {SDL_IMAGE}.make_from_file ("../data/client/setup-window/background.png")>>
        ))

        r.set_with_size (48, 73, 262, 202)
        new_player_list (r)

--        !!setup_window.make (GTK_WINDOW_DIALOG)
--        setup_window.set_title ("Player setup for ~1~")

        r.set_with_size (117, 307, 190, 20)
        !!ruler_name.make (Current, r)

--        customize_button := new_button ("_Customize", $customize_race)
--        flag_view := new_custom_flag_view
--        chat := new_custom_chat

        !BUTTON_IMAGE!start_button.make (Current, 48, 350,
            create {SDL_IMAGE}.make_from_file ("../data/client/connect-window/connect-button-u.png"),
            create {SDL_IMAGE}.make_from_file ("../data/client/connect-window/connect-button-p.png"),
            create {SDL_IMAGE}.make_from_file ("../data/client/connect-window/connect-button-d.png")
            )
        start_button.set_click_handler (agent start_game)

--        retire_button := new_button ("_Retire", $retire_from_game)

        !BUTTON_IMAGE!disconnect_button.make (Current, 268, 350,
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

    player_list: PLAYER_LIST_VIEW
    ruler_name: TEXT_ENTRY
    start_button,
    disconnect_button: BUTTON

feature {NONE} -- Custom widgets

    new_player_list (where: RECTANGLE) is deferred end
    new_flag_view (where: RECTANGLE) is deferred end
    new_chat (where: RECTANGLE) is deferred end

feature {NONE} -- Callbacks

    start_game is
    deferred end

    disconnect is
    deferred end

end -- class SETUP_WINDOW_GUI