class MAIN_WINDOW_GUI

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

        r.set_with_size (0, 0, 640, 480)
        new_galaxy (r)

        !!background.make (Current, 0, 0, create {ANIMATION_FMA}.make (
            "client/main-window/background.fma"))
    end

feature {NONE} -- Widgets

    galaxy: GALAXY_VIEW

    new_galaxy (where: RECTANGLE) is deferred end

end -- class MAIN_WINDOW_GUI
