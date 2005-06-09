deferred class SETUP_WINDOW_GUI

inherit
    WINDOW
    redefine make end

feature {NONE} -- Creation

    make (w: WINDOW; where: RECTANGLE) is
        -- Build GUI
    local
        a: FMA_FRAMESET
        background: WINDOW_IMAGE
        r, s: RECTANGLE
    do
        Precursor (w, where)

        !!a.make ("client/connect-window/background.fma")
        !!background.make (Current, 0, 0, a.images @ 1)
        !!background.make (Current, 0, 0,
            create {IMAGE_FMI}.make_from_file ("client/setup-window/background.fmi"))

        r.set_with_size (75, 100, 235, 175)
        new_player_list (r)

        r.set_with_size (144, 307, 163, 20)
        !!ruler_name.make (Current, r)

	r.set_with_size(320, 100, 135, 175)
	s.set_with_size(455, 100, 135, 175)
	new_radiogroups(r, s)
        
	!BUTTON_IMAGE!start_button.make (Current, 75, 350,
            create {IMAGE_FMI}.make_from_file ("client/connect-window/connect-button-u.fmi"),
            create {IMAGE_FMI}.make_from_file ("client/connect-window/connect-button-p.fmi"),
            create {IMAGE_FMI}.make_from_file ("client/connect-window/connect-button-d.fmi")
            )
        start_button.set_click_handler (agent start_game)

        !BUTTON_IMAGE!disconnect_button.make (Current, 295, 350,
            create {IMAGE_FMI}.make_from_file ("client/connect-window/connect-button-u.fmi"),
            create {IMAGE_FMI}.make_from_file ("client/connect-window/connect-button-p.fmi"),
            create {IMAGE_FMI}.make_from_file ("client/connect-window/connect-button-d.fmi")
            )
        disconnect_button.set_click_handler (agent disconnect)

    end

feature {NONE} -- Widgets

    player_list: PLAYER_LIST_VIEW
    ruler_name: TEXT_ENTRY
    start_button,
    disconnect_button: BUTTON
    race_name_group: RADIOGROUP
    color_group: RADIOGROUP

    new_player_list (where: RECTANGLE) is deferred end
    new_flag_view (where: RECTANGLE) is deferred end
    new_chat (where: RECTANGLE) is deferred end
    new_radiogroups(races_where, color_where: RECTANGLE) is deferred end

feature {NONE} -- Callbacks

    start_game is
    deferred end

    disconnect is
    deferred end

end -- class SETUP_WINDOW_GUI
