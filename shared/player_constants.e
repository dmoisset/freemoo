expanded class PLAYER_CONSTANTS

feature {NONE} -- Constants

    st_setup: INTEGER is 1
    st_ready: INTEGER is 2
    st_playing_turn: INTEGER is 3
    st_waiting_turn_end: INTEGER is 4
    st_end_game: INTEGER is 5
        -- Possible values for `state'

feature -- Constants

    min_state: INTEGER is do Result := st_setup end
        -- Minimum possible `state'
    max_state: INTEGER is do Result := st_end_game end
        -- Maximum possible `state'

    min_color: INTEGER is 0
        -- Minimum possible `color'
    max_color: INTEGER is 7
        -- Maximum possible `color'

feature -- Constants

    color_names: ARRAY[STRING] is
    once
        Result := <<"Red", "Yellow", "Green", "White", "Blue", "Brown", "Violet", "Orange">>
        Result.reindex(0)
    end

end -- class PLAYER_CONSTANTS
