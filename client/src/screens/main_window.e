class MAIN_WINDOW
    -- Main game window

inherit
    MAIN_WINDOW_GUI
    GETTEXT
    CLIENT
    PLAYER_CONSTANTS

creation
    make

feature -- Operations

    activate is
    require
        server /= Void
    do
        show
    end

feature {NONE} -- Widgets

    new_galaxy (where: RECTANGLE) is
    do
        !!galaxy.make (Current, where, server.galaxy)
    end

end -- class MAIN_WINDOW