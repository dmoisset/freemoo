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

        !!a.make ("client/main-window/turn-button.fma")
        !BUTTON_IMAGE!end_turn_button.make (Current, 544, 441,
            a.images @ 1, a.images @ 1, a.images @ 2)
        end_turn_button.set_click_handler (agent end_turn)

        r.set_with_size (549, 27, 63, 13)
        new_date (r)
    end

feature {NONE} -- Widgets

    galaxy: GALAXY_VIEW
    end_turn_button: BUTTON

    new_galaxy (where: RECTANGLE) is deferred end
    new_date (where: RECTANGLE) is deferred end

feature {NONE} -- Callbacks

    end_turn is
    deferred end

end -- class MAIN_WINDOW_GUI
