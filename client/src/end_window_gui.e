deferred class END_WINDOW_GUI

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
        !!a.make ("client/connect-window/background.fma")
        !!background.make (Current, 0, 0, a.images @ 1)

        r.set_with_size (48, 350, 300, 25)
        !!label.make(background, r, l("GAME OVER"))
    end

feature {NONE} -- Widgets

    background: WINDOW_IMAGE
    label: LABEL

end -- class END_WINDOW_GUI
