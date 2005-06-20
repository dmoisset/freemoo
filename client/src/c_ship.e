class C_SHIP
inherit
    SHIP
    SUBSCRIBER
    CLIENT

creation make

feature

    on_message (msg: STRING; provider: SERVICE_PROVIDER; service: STRING) is
        -- Action when `msg' arrives from `provider''s `service'
    local
        s: UNSERIALIZER
    do
        !!s.start (msg)
        s.get_boolean
        is_stealthy := s.last_boolean
    end

    unserialize_from (s: UNSERIALIZER) is
    do
        s.get_integer
        creator := server.player_list.item_id(s.last_integer)
    end

end -- class C_SHIP
