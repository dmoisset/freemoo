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
        ir: INTEGER_REF
        br: BOOLEAN_REF
    do
        s.unserialize ("ibbiiibbb", msg)
        ir ?= s.unserialized_form @ 1; open_slots := ir.item
        br ?= s.unserialized_form @ 2; finished := br.item
        br ?= s.unserialized_form @ 3; started := br.item
        ir ?= s.unserialized_form @ 4; galaxy_size := ir.item
        ir ?= s.unserialized_form @ 5; galaxy_age := ir.item
        ir ?= s.unserialized_form @ 6; start_tech_level := ir.item
        br ?= s.unserialized_form @ 7; tactical_combat := br.item
        br ?= s.unserialized_form @ 8; random_events := br.item
        br ?= s.unserialized_form @ 9; antaran_attacks := br.item

        notify_views
    end

end -- class C_GAME_STATUS