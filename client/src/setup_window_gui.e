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
        build_radio_groups
        
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

    build_radio_groups is
    local
        r: RECTANGLE
        p: PLAYER_CONSTANTS
        i: ITERATOR [STRING]
        b: RADIO_BUTTON_IMAGE
        bup, bdown: IMAGE_FMI
    do
        create bup.make_from_file("client/setup-window/radio-button-u.fmi")
        create bdown.make_from_file("client/setup-window/radio-button-d.fmi")
        create races.make
        -- Races
        create race.make
        r.set_with_size (320, 100, 135, 15)
        from
            i := races.race_names.get_new_iterator
        until i.is_off loop
            create b.make_with_label (Current, r, bup, bdown, i.item, race)
            r.translate (0, 18)
            i.next
        end
        -- Colors
        create color.make
        r.set_with_size(455, 100, 135, 15)
        from
            i := p.color_names.get_new_iterator_on_items
        until i.is_off loop
            create b.make_with_label (Current, r, bup, bdown, i.item, color)
            r.translate (0, 18)
            i.next
        end

    end
        
feature {NONE} -- Widgets

    player_list: PLAYER_LIST_VIEW
    ruler_name: TEXT_ENTRY
    start_button,
    disconnect_button: BUTTON
    race: RADIO_GROUP
    color: RADIO_GROUP

    races: RACE_ATTRIBUTES

    new_player_list (where: RECTANGLE) is deferred end
    new_flag_view (where: RECTANGLE) is deferred end
    new_chat (where: RECTANGLE) is deferred end

feature {NONE} -- Callbacks

    start_game is
    deferred end

    disconnect is
    deferred end

end -- class SETUP_WINDOW_GUI
