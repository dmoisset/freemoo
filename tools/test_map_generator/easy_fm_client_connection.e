class EASY_FM_CLIENT_CONNECTION
    -- Hack class to force an FM_CLIENT_CONNECTION

inherit
    FM_CLIENT_CONNECTION

creation easy_make

feature {NONE} -- Creation

    easy_make(plist: C_PLAYER_LIST; gal: C_GALAXY; god: C_PLAYER) is
    do
        player_list := plist
        galaxy := gal
        player := god
    end

end -- Class EASY_FM_CLIENT_CONNECTION