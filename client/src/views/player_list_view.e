class PLAYER_LIST_VIEW
    -- View for a PLAYER_LIST

inherit
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

    make (w: WINDOW; where: RECTANGLE; new_players: C_PLAYER_LIST) is
        -- build widget as view of `new_players'
    do
        !!labels.make (1, 0)
        window_make (w, where)
        players := new_players
        players.changed.connect (agent update_players)

        -- Update gui
        update_players (players)
    end

feature {NONE} -- Representation

    labels: ARRAY [LABEL]

    players: C_PLAYER_LIST

    update_players (pl: C_PLAYER_LIST) is
        -- Update gui
    require
        pl = players
    local
        i: ITERATOR [C_PLAYER]
        j: INTEGER
        s: STRING
        r: RECTANGLE
    do
        i := players.get_new_iterator
        from
            i.start
            j := labels.lower
        until i.is_off loop
            s := i.item.name.twin
            s.append (": "+ state_names @ i.item.state)
            if i.item.connected then
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

feature {NONE} -- Constants

    state_names: ARRAY [STRING] is
    once
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