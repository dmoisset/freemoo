class PLAYER

inherit
    PLAYER_CONSTANTS
    UNIQUE_ID

feature {NONE} -- Creation

    make is
    do
        set_state (st_setup)
        set_color (min_color)
        !!colonies.make
        !!knows_star.make
        !!has_visited_star.make
    ensure
        state = st_setup
    end

feature -- Access

    name: STRING
        -- Player name

    color: INTEGER
        -- a unique color
        
    colonies: DICTIONARY [COLONY, INTEGER]
        -- Colonies owned by this player
        
    knows_star: SET[STAR]
        -- Stars known by this player
    
    has_visited_star: SET[STAR]
        -- Stars visited by this player

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

feature -- Special abilities

    sees_all_ships: BOOLEAN

feature {PLAYER_LIST} -- Operations

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
        color := new_color
    ensure
        color = new_color
    end
    
feature {COLONY} -- Operations

    add_colony (colony: COLONY) is
    require
        not colonies.has (colony.id)
    do
        colonies.add (colony, colony.id)
    ensure
        colonies.has (colony.id)
    end

    remove_colony (colony: COLONY) is
    require
        colonies.has (colony.id)
    do
        colonies.remove (colony.id)
    ensure
        not colonies.has (colony.id)
    end

feature {MAP_GENERATOR, FLEET} 

    add_to_known_list (star: STAR) is
    do
        knows_star.add (star)
    end
    
    add_to_visited_list (star: STAR) is
    do
        has_visited_star.add (star)
    end

invariant
    valid_state: state.in_range (min_state, max_state)
    valid_color: color.in_range (min_color, max_color)

end -- class PLAYER
