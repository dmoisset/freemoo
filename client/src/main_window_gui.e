class MAIN_WINDOW_GUI

inherit
    WINDOW
    redefine make, focusable end

feature {NONE} -- Creation

    make (w: WINDOW; where: RECTANGLE) is
        -- Build GUI
    local
        background: WINDOW_ANIMATED
    do
        Precursor (w, where)

        !!background.make (Current, 0, 0, create {ANIMATION_FMA}.make (
            "client/main-window/background.fma"))
    end

feature -- Redefined features

    focusable: BOOLEAN is True

feature {NONE} -- Widgets

end -- class MAIN_WINDOW_GUI
