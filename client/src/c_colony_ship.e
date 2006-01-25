class C_COLONY_SHIP

inherit
    COLONY_SHIP
        undefine
            make
        redefine planet_to_colonize, owner end
    C_SHIP
        redefine on_message, owner end

create
    make

feature -- Redefined features

    owner: like creator

    on_message (msg: STRING; provider: SERVICE_PROVIDER; service: STRING) is
        -- Action when `msg' arrives from `provider''s `service'
    local
        s: UNSERIALIZER
        star: C_STAR
    do
        create s.start (msg)
        s.get_integer
        if s.last_integer = -1 then
            s.get_integer
            planet_to_colonize := Void
        else
            star := server.galaxy.star_with_id(s.last_integer)
            check star /= Void end
            s.get_integer
            planet_to_colonize := star.planet_at(s.last_integer)
        end
    end

feature -- Access

    planet_to_colonize: C_PLANET

end -- class C_COLONY_SHIP
