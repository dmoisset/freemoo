class EASY_PLAYER_LIST
inherit
    PLAYER_LIST[PLAYER]
    redefine add

creation
    make



feature {NONE} -- Implementation
    color: INTEGER

feature
    add (p:PLAYER) is
    do
        items.add (p, p.name)
    end

end -- class EASY_PLAYER_LIST
