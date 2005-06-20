class C_STARSHIP

inherit
    C_SHIP
    redefine unserialize_from, on_message, make end
    STARSHIP
    redefine make end

creation make

feature

    on_message (msg: STRING; provider: SERVICE_PROVIDER; service: STRING) is
        -- Action when `msg' arrives from `provider''s `service'
    local
        s: UNSERIALIZER
    do
        !!s.start (msg)
        s.get_string
        name := s.last_string
        s.get_real
        fuel_range := s.last_real
        s.get_boolean
        is_stealthy := s.last_boolean
    end

    unserialize_from (s: UNSERIALIZER) is
    do
        Precursor(s)
        s.get_integer
        size := s.last_integer
        s.get_integer
        picture := s.last_integer
    end

feature {NONE} -- Creation

    make(p: like creator) is
    do
        Precursor{C_SHIP}(p)
        set_starship_attributes
    end

end -- class C_STARSHIP