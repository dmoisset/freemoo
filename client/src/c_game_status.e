class C_GAME_STATUS
    -- Public status of the server (client view)

inherit
    GAME_STATUS
    undefine
        fill_slot, finish
    redefine
        make
    end
    SUBSCRIBER
    MODEL

creation
    make

feature -- Creation

    make is
    do
        Precursor
        make_model
    end

feature {SERVICE_PROVIDER} -- Subscriber callback

    on_message (msg: STRING; provider: SERVICE_PROVIDER; service: STRING) is
        -- Action when `msg' arrives from `provider''s `service'
    local
        s: UNSERIALIZER
    do
        !!s.start (msg)
        s.get_integer; open_slots := s.last_integer
        s.get_boolean; finished := s.last_boolean
        s.get_boolean; started := s.last_boolean
        s.get_integer; galaxy_size := s.last_integer
        s.get_integer; galaxy_age := s.last_integer
        s.get_integer; start_tech_level := s.last_integer
        s.get_boolean; tactical_combat := s.last_boolean
        s.get_boolean; random_events := s.last_boolean
        s.get_boolean; antaran_attacks := s.last_boolean
        s.get_integer; date := s.last_integer
        notify_views
    end

end -- class C_GAME_STATUS