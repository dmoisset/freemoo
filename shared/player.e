class PLAYER

inherit
    PLAYER_CONSTANTS

feature {NONE} -- Creation

    make is
    do
        set_state (st_setup)
        set_color (min_color)
    ensure
        state = st_setup
    end

feature -- Access

    name: STRING
        -- Player name

    color_id: INTEGER
        -- a unique color_id

feature -- Access

    --
    -- The player moves through a simple state loop. Possible `state' is:
    --   st_setup: Selecting race name, options, color, etc.
    --   st_ready: Waiting for game to begin
    --   st_playing_turn: Doing main turn actions (giving orders to fleets,
    --                    colonies), etc.
    --   st_waiting_turn_end: finished giving turn orders, waiting for others.
    --   st_end_game: The game is over for this player.

    state: INTEGER
        -- State on the game

feature -- Operations

    set_state (new_state: INTEGER) is
    require
        new_state.in_range (min_state, max_state)
    do
        state := new_state
    ensure
        state = new_state
    end

    set_color (new_color: INTEGER) is
    require
        new_color.in_range (min_color, max_color)
    do
        color_id := new_color
    ensure
        color_id = new_color
    end

invariant
    valid_state: state.in_range (min_state, max_state)
    valid_color: color_id.in_range (min_color, max_color)

end -- class PLAYER