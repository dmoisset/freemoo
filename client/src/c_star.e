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
        ir: reference INTEGER
        pcount: INTEGER
        s: SERIALIZER
        orbit: INTEGER
        todays_planets: SET[INTEGER]
    do
        !!todays_planets.make
        newmsg := msg
        has_info := True
        s.unserialize ("si", newmsg)
        name ?= s.unserialized_form @ 1
        ir ?= s.unserialized_form @ 2
        pcount := ir
        newmsg.remove_first(s.used_serial_count)
        from until pcount = 0 loop
            s.unserialize ("iiiiiii", newmsg)
            ir ?= s.unserialized_form @ 7
            orbit := ir
            todays_planets.add(orbit)
            if (planets @ orbit) = Void then
                set_planet(create{PLANET}.make_standard (Current), orbit)
            end
            ir ?= s.unserialized_form @ 1
-- Using .item below because of SE bug #152
            planets.item(orbit).set_size (ir.item + plsize_min)
            ir ?= s.unserialized_form @ 2
            planets.item(orbit).set_climate (ir.item + climate_min)
            ir ?= s.unserialized_form @ 3
            planets.item(orbit).set_mineral (ir.item + mnrl_min)
            ir ?= s.unserialized_form @ 4
            planets.item(orbit).set_gravity (ir.item + grav_min)
            ir ?= s.unserialized_form @ 5
            planets.item(orbit).set_type (ir.item + type_min)
            ir ?= s.unserialized_form @ 6
            planets.item(orbit).set_special (ir.item + plspecial_min)
            pcount := pcount - 1
            newmsg.remove_first(s.used_serial_count)
        end
-- remove stale planets
        from pcount := 1
        until pcount > 5 loop
            if planets.item(pcount) /= Void and not todays_planets.has(pcount) then
                planets.remove(pcount)
            end
            pcount := pcount + 1
        end
        notify_views
    end

feature -- Accounting

    has_info: BOOLEAN
        -- Player has planet info

end -- class C_STAR