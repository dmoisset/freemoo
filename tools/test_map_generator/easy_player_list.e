class EASY_PLAYER_LIST
inherit
    C_PLAYER_LIST
        redefine add end

creation
    make



feature {NONE} -- Implementation
    color: INTEGER

feature
    add (p:EASY_PLAYER) is
    do
        items.add (p, p.name)
    end

end -- class EASY_PLAYER_LIST
