class C_RACE

inherit 
    RACE
    SUBSCRIBER

creation make

feature

    on_message (msg: STRING; provider: SERVICE_PROVIDER; service: STRING) is
        -- Action when `msg' arrives from `provider''s `service'
    local
        s: UNSERIALIZER
    do
        print ("in race's on_message!%N")
        !!s.start (msg)
        unserialize_from(s)
    end


end
