class PLAYER_LIST_VIEW
    -- Gtk view for a PLAYER_LIST

inherit
    VIEW [C_PLAYER_LIST]
    VEGTK_HELPER
    GETTEXT
    PLAYER_CONSTANTS
    COLORS

creation
    make

feature {NONE} -- Creation

    make (new_model: C_PLAYER_LIST) is
        -- build widget as view of `new_model'
    do
        set_model (new_model)

        !!list.make_with_titles (3, <<l("Name"), l("Status"), l("Connected")>>)
        list.set_column_auto_resize (0, True)
        list.set_column_auto_resize (1, True)
        list.set_column_justification (2, Gtk_justify_center)
        list.set_usize (300, 150)
        list.set_border_width (border_width)
        list.column_titles_show
        widget := new_scrolled_window (list)

        -- Update gui
        on_model_change
    end

feature -- Access

    widget: GTK_WIDGET
        -- widget reflecting model

feature {NONE} -- Internal

    list: GTK_CLIST

feature -- Redefined features

    on_model_change is
        -- Update gui
    local
        a: ARRAY [STRING]
        p: C_PLAYER
        i, dummy: INTEGER
    do
        list.freeze
        list.clear
        a := model.names
        from i := a.lower until i > a.upper loop
            p := model @ (a @ i)
            dummy := list.append (<<p.name, state_names @ p.state, " ">>)
            if p.connected then
                list.set_text (i-1, 2, "*")
            end
            list.set_background (i-1, color_map @ p.color_id)
            list.set_foreground (i-1, gdk_black)

            i := i + 1
        end
        list.thaw
    end

feature {NONE} -- Constants

    gdk_black: GDK_COLOR is
    once
        !!Result.make_with_values (0, 0, 0)
    end

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