class
    EASY_PLAYER

inherit
    UNIQUE_ID
    C_PLAYER
	rename make as c_make, add_to_known_list as foo end
    S_PLAYER
	rename make as s_make end
    PLAYER_CONSTANTS

creation with_name

feature {NONE} -- Creation
    with_name (n:STRING; c: INTEGER) is
    require
        n /= Void
        c.in_range(min_color, max_color)
    do
        player_make
        name := n
        color := c
        make_unique_id
    end

end -- Class EASY_PLAYER
