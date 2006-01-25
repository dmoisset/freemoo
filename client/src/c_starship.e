class C_STARSHIP

inherit
    C_SHIP
        undefine
            make
        redefine
            unserialize_from, on_message
        end
    STARSHIP

create
    make

feature

    on_message (msg: STRING; provider: SERVICE_PROVIDER; service: STRING) is
        -- Action when `msg' arrives from `provider''s `service'
    local
        s: UNSERIALIZER
    do
        create s.start (msg)
        unserialize_completely_from(s)
    end

    unserialize_completely_from(s: UNSERIALIZER) is
    do
        s.get_string
        name := s.last_string
    end

    unserialize_from (s: UNSERIALIZER) is
    do
        Precursor(s)
        s.get_integer
        size := s.last_integer
        s.get_integer
        picture := s.last_integer
    end

end -- class C_STARSHIP
