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

    new_date (where: RECTANGLE) is
    local
        v: DATE_VIEW
    do
        !!v.make (Current, where, server.game_status)
    end

feature {NONE} -- Callbacks

    end_turn is
    do
        server.end_turn (False)
    end

    game_menu, colonies, planets, fleets, zoomin, zoomout, leaders, races, info is
    do
        print ("Not yet implemented%N")
    end

end -- class MAIN_WINDOW