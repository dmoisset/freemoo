class
    EASY_PLAYER

inherit
    UNIQUE_ID
    PLAYER
    PLAYER_CONSTANTS

creation with_name

feature {NONE} -- Creation
    with_name (n:STRING; c: INTEGER) is
    require
        n /= Void
        c.in_range(min_color, max_color)
    do
        make
        name := n
        color := c
        make_unique_id
    end

end -- Class EASY_PLAYER
