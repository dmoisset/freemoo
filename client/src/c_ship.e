deferred class C_SHIP

inherit
    SHIP
    SUBSCRIBER
    CLIENT

feature

    unserialize_from (s: UNSERIALIZER) is
    do
        s.get_integer
        creator := server.player_list.item_id(s.last_integer)
    end

end -- class C_SHIP
