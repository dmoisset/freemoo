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
    
    new_player_status (where: RECTANGLE) is
    local
        p: PLAYER_STATUS_VIEW
    do
        !!p.make (Current, where, server.player_list)
    end

feature {NONE} -- Callbacks

    end_turn is
    do
        server.end_turn (False)
    end

	game_menu is
	do
		server.save_game
	end
	
    colonies, planets, fleets, leaders, races, info is
    do
        print ("Not yet implemented%N")
    end

    zoomin is
    do
        galaxy.zoom_in (galaxy.width//2, galaxy.height//2)
    end

    zoomout is
    do
        galaxy.zoom_out (galaxy.width//2, galaxy.height//2)
    end
end -- class MAIN_WINDOW
