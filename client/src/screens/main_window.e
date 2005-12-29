class MAIN_WINDOW
    -- Main game window

inherit
    MAIN_WINDOW_GUI
        redefine make end
    GETTEXT
    CLIENT
    PLAYER_CONSTANTS
    DIALOG_KINDS
        export {NONE} all end

creation
    make

feature {NONE} -- Creation

    make (w: WINDOW; where: RECTANGLE) is
    do
        Precursor (w, where)
        server.dialogs.on_dialog_addition.connect (agent new_dialog)
    end

    new_dialog (args: TUPLE[INTEGER, INTEGER, STRING]) is
    local
        id, kind: INTEGER
        dinfo: STRING
    do
        id := args.first
        kind := args.second
        dinfo := args.third
        inspect kind
        when dk_colonization then
            on_colonize_dialog (id, dinfo)
        when dk_engage then
            on_engagement_dialog (id, dinfo)
        else
            print ("Unrecognized dialog kind%N")
        end
    end

    on_colonize_dialog (id: INTEGER; dinfo: STRING) is
    local
        u: UNSERIALIZER
        f: C_FLEET
    do
        create u.start (dinfo)
        u.get_integer
        f := server.galaxy.fleet_with_id (u.last_integer)
        galaxy.select_planet_for_colonization (id, f)
    end

    on_engagement_dialog (id: INTEGER; dinfo: STRING) is
    local
        u: UNSERIALIZER
        f: C_FLEET
    do
        create u.start (dinfo)
        u.get_integer
        f := server.galaxy.fleet_with_id (u.last_integer)
        galaxy.select_target (id, f)
    end

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

    new_money(where: RECTANGLE) is
    do
        create money.make(Current, where, server.player)
    end

    new_turn_summary is
    do
        create turn_summary_window.make(Current, server.player)
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
