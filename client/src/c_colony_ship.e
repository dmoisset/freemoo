class C_COLONY_SHIP

inherit
    COLONY_SHIP
        redefine make, planet_to_colonize, owner end
    C_SHIP
        redefine make, on_message, unserialize_from, owner end

creation make

feature {NONE} -- Creation

    make(p: like creator) is
    do
        Precursor{C_SHIP}(p)
        set_colony_ship_attributes
    end

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

    unserialize_from (s: UNSERIALIZER) is
    do
        s.get_integer
        creator := server.player_list.item_id(s.last_integer)
    end

feature -- Access

    planet_to_colonize: C_PLANET

end -- class C_COLONY_SHIP
