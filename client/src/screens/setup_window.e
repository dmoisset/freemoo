class SETUP_WINDOW

inherit
    SETUP_WINDOW_GUI
    redefine handle_event end
    CLIENT
    GETTEXT
    STRING_FORMATTER
    PLAYER_CONSTANTS

creation
    make

feature -- Operations

    activate is
    require
        server /= Void and not server.is_closed
        server.player_name /= Void
        server.player /= Void
    do
--        setup_window.set_title (format(l("Player setup for ~1~"),
--                                     <<server.player_name>>))
        show
        ruler_name.grab
    end

feature -- Redefined features

    handle_event (event:EVENT) is
    local
        n: EVENT_NETWORK
    do
        Precursor (event)
        n ?= event
        if n /= Void then
            on_network_event
        end
    end

feature {NONE} -- Callbacks

    start_game is
    do
        server.set_ready
    end

    disconnect is
    do
        server.close
        destroy
    end

    destroy is
        -- Close and hide window
    do
        hide
--        flag_viewer.widget.hide
    end

    on_network_event is
        -- Check network
    do
        if server.is_closed or not server.has_joined or server.game_status.started then
            destroy
        end
    end

feature {NONE} -- Custom widgets

    new_player_list (where: RECTANGLE) is
    do
        !!player_list.make (Current, where, server.player_list)
    end

--    new_custom_flag_view: GTK_WIDGET is
--    do
--        !!flag_viewer.make (server.player_list)
--        Result := flag_viewer.widget
--    end
--
--    new_custom_chat: GTK_WIDGET is
--    do
--        print ("Not implemented%N")
--        !GTK_LABEL!Result.make ("chat")
--    end

end -- class SETUP_WINDOW