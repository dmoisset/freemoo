deferred class SETUP_WINDOW_GUI

inherit
    WINDOW
    redefine make end

feature {NONE} -- Creation

    make (w: WINDOW; where: RECTANGLE) is
        -- Build GUI
    local
        background: WINDOW_ANIMATED
        r: RECTANGLE
    do
        Precursor (w, where)

        !!background.make (Current, 0, 0, create {ANIMATION_FMA}.make (
            "client/connect-window/background.fma"))
        !!background.make (Current, 0, 0, create {ANIMATION_SEQUENTIAL}.make (
            <<create {IMAGE_FMI}.make_from_file ("client/setup-window/background.fmi")>>
        ))

        r.set_with_size (75, 100, 235, 175)
        new_player_list (r)

--        !!setup_window.make (GTK_WINDOW_DIALOG)
--        setup_window.set_title ("Player setup for ~1~")

        r.set_with_size (144, 307, 163, 20)
        !!ruler_name.make (Current, r)

--        customize_button := new_button ("_Customize", $customize_race)
--        flag_view := new_custom_flag_view
--        chat := new_custom_chat

        !BUTTON_IMAGE!start_button.make (Current, 75, 350,
            create {IMAGE_FMI}.make_from_file ("client/connect-window/connect-button-u.fmi"),
            create {IMAGE_FMI}.make_from_file ("client/connect-window/connect-button-p.fmi"),
            create {IMAGE_FMI}.make_from_file ("client/connect-window/connect-button-d.fmi")
            )
        start_button.set_click_handler (agent start_game)

--        retire_button := new_button ("_Retire", $retire_from_game)

        !BUTTON_IMAGE!disconnect_button.make (Current, 295, 350,
            create {IMAGE_FMI}.make_from_file ("client/connect-window/connect-button-u.fmi"),
            create {IMAGE_FMI}.make_from_file ("client/connect-window/connect-button-p.fmi"),
            create {IMAGE_FMI}.make_from_file ("client/connect-window/connect-button-d.fmi")
            )
        disconnect_button.set_click_handler (agent disconnect)

        hide
    end

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
