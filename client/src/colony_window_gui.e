deferred class COLONY_WINDOW_GUI

inherit
    WINDOW
    redefine make end
    GETTEXT

feature {NONE} -- Creation

    make (w: WINDOW; where: RECTANGLE) is
        -- Build GUI
    local
        a: FMA_FRAMESET
        r: RECTANGLE
    do
        Precursor (w, where)
        !!a.make ("client/colony-window/colony-background.fma")
        !!background.make (Current, 0, 0, a.images @ 1)

        !!a.make ("client/colony-window/close1.fma")
        !BUTTON_IMAGE!close_button.make(background, 556, 449,
             create {SDL_SOLID_IMAGE}.make(0, 0, 80,80,250),
             a.images @ 1,a.images @ 1)
        close_button.set_click_handler(agent close)
    end

feature {NONE} -- Widgets

    background: WINDOW_IMAGE
    close_button: BUTTON

feature {NONE} -- Callbacks

    close is
    local
        connection_window: CONNECTION_WINDOW
    do
        connection_window ?= parent
        hide
        connection_window.goto_main_window
    end

end -- class COLONY_WINDOW_GUI
