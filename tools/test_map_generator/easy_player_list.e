class EASY_PLAYER_LIST
inherit
    PLAYER_LIST[PLAYER]
        redefine add end
    IDMAP_ACCESS

creation
    make



feature {NONE} -- Implementation
    color: INTEGER

feature
    add (p:EASY_PLAYER) is
    do
        items.add (p, p.name)
        idmap.put (p, p.id)
    end

end -- class EASY_PLAYER_LIST
