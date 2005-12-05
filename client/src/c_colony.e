class C_COLONY

inherit
    COLONY
    redefine make end
    SUBSCRIBER

creation
    make

feature {NONE} -- Creation

    make (p: like location; o: like owner) is
    do
        Precursor(p, o)
        create changed.make
    end

feature

    on_message (msg: STRING; provider: SERVICE_PROVIDER; service: STRING) is
        -- Action when `msg' arrives from `provider''s `service'
    local
        s: UNSERIALIZER
    do
        !!s.start (msg)
        s.get_integer
        producing := s.last_integer + product_min
        s.get_integer
        population := s.last_integer
        changed.emit(Current)
    end

feature -- Signals

    changed: SIGNAL_1 [C_COLONY]

end -- class C_COLONY
