class PLAYER_LIST_VIEW
    -- View for a PLAYER_LIST

inherit
    VIEW [C_PLAYER_LIST]
    WINDOW
    rename
        make as window_make
    redefine
        redraw
    end
    GETTEXT
    PLAYER_CONSTANTS
    COLORS

creation
    make

feature {NONE} -- Creation

    make (w: WINDOW; where: RECTANGLE; new_model: C_PLAYER_LIST) is
        -- build widget as view of `new_model'
    do
        window_make (w, where)
        set_model (new_model)
        !!pic.make (width, height)

        -- Update gui
        on_model_change
    end

feature {NONE} -- Internal

    pic: SDL_IMAGE

feature -- Redefined features

    on_model_change is
        -- Update gui
    local
        a: ARRAY [STRING]
        p: C_PLAYER
        i: INTEGER
        s: STRING
    do
        !!pic.make (width, height)
        a := model.names
        from i := a.lower until i > a.upper loop
            p := model @ (a @ i)
            s := p.name.twin
            s.append (": "+ state_names @ p.state)
            if p.connected then
                s.add_first ('*')
            end
            if display.default_font /= Void then
-- color adecuado
                display.default_font.show_at (pic, 2, (i-1)*20+2, s)
            end
            i := i + 1
        end

        request_redraw_all
    end

    redraw (area: RECTANGLE) is
    local
        w: RECTANGLE
    do
        w.set_with_size (0, 0, width, height)
        show_image (pic, 0, 0, w)
        Precursor (area)
    end


feature {NONE} -- Constants

    state_names: ARRAY [STRING] is
    do
        !!Result.make (min_state, max_state)
        Result.put (l("Preparing"), st_setup)
        Result.put (l("Ready for game"), st_ready)
        Result.put (l("Playing"), st_playing_turn)
        Result.put (l("Waiting"), st_waiting_turn_end)
        Result.put (l("Finished"), st_end_game)
    end

end -- PLAYER_LIST_VIEW