class MAIN_WINDOW_GUI

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

        r.set_with_size (21, 21, 508, 402)
        new_galaxy (r)

        !!a.make ("client/main-window/background.fma")
        !!background.make (Current, 0, 0, a.images @ 1)

        !!a.make ("client/main-window/game-button.fma")
        !BUTTON_IMAGE!game_button.make (Current, 249, 5,
            a.images @ 1, a.images @ 1, a.images @ 2)
        game_button.set_click_handler (agent game_menu)

        !!a.make ("client/main-window/turn-button.fma")
        !BUTTON_IMAGE!end_turn_button.make (Current, 544, 441,
            a.images @ 1, a.images @ 1, a.images @ 2)
        end_turn_button.set_click_handler (agent end_turn)

        !!a.make ("client/main-window/colonies-button.fma")
        !POLY_BUTTON!left_buttons.make (Current, 0, 425, a.images @ 1)
        r.set_with_size (4, 0, 76, 55)
        left_buttons.add_click_handler (r, agent colonies, a.images @ 2)
        !!a.make ("client/main-window/planets-button.fma")
        r.set_with_size (91, 0, 67, 55)
        left_buttons.add_click_handler (r, agent planets, a.images @ 2)
        !!a.make ("client/main-window/fleets-button.fma")
        r.set_with_size (166, 0, 66, 55)
        left_buttons.add_click_handler (r, agent fleets, a.images @ 2)

        r.set_with_size (549, 27, 63, 13)
        new_date (r)
    end

feature {NONE} -- Widgets

    galaxy: GALAXY_VIEW
    game_button,
    end_turn_button: BUTTON
    left_buttons, right_buttons: POLY_BUTTON

    new_galaxy (where: RECTANGLE) is deferred end
    new_date (where: RECTANGLE) is deferred end

feature {NONE} -- Callbacks

    end_turn is
    deferred end

    game_menu is
    deferred end

    colonies is
    deferred end

    planets is
    deferred end

    fleets is
    deferred end

end -- class MAIN_WINDOW_GUI
