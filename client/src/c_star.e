class C_STAR
    -- Star system, client's view
    -- This model can have incomplete information.

inherit
    STAR
        redefine make, make_defaults end
    MODEL
    SUBSCRIBER

creation
    make, make_defaults

feature {NONE} -- Creation

    make (p:POSITIONAL; n:STRING; k:INTEGER; s:INTEGER) is
    do
        Precursor (p, n, k, s)
        make_model
    end

    make_defaults is
    do
        Precursor
        make_model
    end

feature {SERVICE_PROVIDER} -- Redefined features

    on_message (msg: STRING; provider: SERVICE_PROVIDER; service: STRING) is
        -- Action when `msg' arrives from `provider''s `service'
    local
        newmsg: STRING
        ir: INTEGER_REF
        pcount: INTEGER
        new_planets: ARRAY[PLANET]
        planet: PLANET
        s: SERIALIZER
        orbit: INTEGER
    do
        newmsg := msg

        has_been_visited := True
        s.unserialize ("si", newmsg)
        name ?= s.unserialized_form @ 1
        ir ?= s.unserialized_form @ 2
        pcount := ir.item
        newmsg.remove_first(s.used_serial_count)
        !!new_planets.make (1, 5)
        -- If I could be sure that planets come in ascending orbit, I'd edit
        -- in place...  even better if i could be sure planets don't dissapear.
        -- What happens to a colony if it's planet dissapears?
        from until pcount = 0 loop
            s.unserialize ("iiiiiii", newmsg)
            ir ?= s.unserialized_form @ 7
            orbit := ir.item
            if (planets @ orbit) /= Void then
                planet := planets@orbit
            else
                !!planet.make_standard(Current)
            end
            ir ?= s.unserialized_form @ 1
            planet.set_size (ir.item + plsize_min)
            ir ?= s.unserialized_form @ 2
            planet.set_climate (ir.item + climate_min)
            ir ?= s.unserialized_form @ 3
            planet.set_mineral (ir.item + mnrl_min)
            ir ?= s.unserialized_form @ 4
            planet.set_gravity (ir.item + grav_min)
            ir ?= s.unserialized_form @ 5
            planet.set_type (ir.item + type_min)
            ir ?= s.unserialized_form @ 6
            planet.set_special (ir.item + plspecial_min)
            planet.set_orbit (orbit)
            new_planets.put(planet, orbit)
            pcount := pcount - 1
            newmsg.remove_first(s.used_serial_count)
        end
        planets := new_planets
        notify_views
    end

feature -- Accounting

    has_been_visited: BOOLEAN

end -- class C_STAR