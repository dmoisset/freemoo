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
        s: SERIALIZER
        ir: reference INTEGER
        br: reference BOOLEAN
    do
        s.unserialize ("ibbiiibbbi", msg)
        ir ?= s.unserialized_form @ 1; open_slots := ir
        br ?= s.unserialized_form @ 2; finished := br
        br ?= s.unserialized_form @ 3; started := br
        ir ?= s.unserialized_form @ 4; galaxy_size := ir
        ir ?= s.unserialized_form @ 5; galaxy_age := ir
        ir ?= s.unserialized_form @ 6; start_tech_level := ir
        br ?= s.unserialized_form @ 7; tactical_combat := br
        br ?= s.unserialized_form @ 8; random_events := br
        br ?= s.unserialized_form @ 9; antaran_attacks := br
        ir ?= s.unserialized_form @ 10; date := ir
        notify_views
    end

end -- class C_GAME_STATUS