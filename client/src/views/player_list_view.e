class PLAYER_LIST_VIEW
    -- View for a PLAYER_LIST

inherit
    VIEW [C_PLAYER_LIST]
    WINDOW
    rename
        make as window_make
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
        !!labels.make (1, 0)
        window_make (w, where)
        set_model (new_model)

        -- Update gui
        on_model_change
    end

feature -- Redefined features

    on_model_change is
        -- Update gui
    local
        i: ITERATOR [STRING]
        j: INTEGER
        p: C_PLAYER
        s: STRING
        r: RECTANGLE
    do
        i := model.names.get_new_iterator
        from
            i.start
            j := labels.lower
        until i.is_off loop
            p := model @ i.item
            s := p.name.twin
            s.append (": "+ state_names @ p.state)
            if p.connected then
                s.add_first ('*')
            end
            if j > labels.upper then
                r.set_with_size (2, (j-1)*20+2, width-4, 20)
                labels.add_last (create {LABEL}.make (Current, r, ""))
                labels.item (j).set_h_alignment (0)
            end
-- color adecuado
            labels.item (j).set_text (s)
            i.next
            j := j + 1
        end
        -- Remove remaining labels.
        from until j > labels.upper loop
            labels.item (j).remove
            labels.remove (j)
        end
    end

feature {NONE} -- Widgets

    labels: ARRAY [LABEL]

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

invariant
    labels /= Void
    labels.lower = 1

end -- PLAYER_LIST_VIEW