class C_STAR
    -- Star system, client's view
    -- This model can have incomplete information.

inherit
    STAR
    redefine make, make_defaults, fleet_type, add_fleet end
    SUBSCRIBER

creation
    make, make_defaults

feature {NONE} -- Creation

    make (p:POSITIONAL; n:STRING; k:INTEGER; s:INTEGER) is
    do
        Precursor (p, n, k, s)
        create changed.make
    end

    make_defaults is
    do
        Precursor
        create changed.make
    end

feature {SERVICE_PROVIDER} -- Redefined features

    on_message (msg: STRING; provider: SERVICE_PROVIDER; service: STRING) is
        -- Action when `msg' arrives from `provider''s `service'
    local
        pcount: INTEGER
        s: UNSERIALIZER
        orbit: INTEGER
        todays_planets: SET[INTEGER]
    do
        !!todays_planets.make
        !!s.start (msg)
        has_info := True
        s.get_string; name := s.last_string
        s.get_integer; pcount := s.last_integer
        from until pcount = 0 loop
            s.get_integer; orbit := s.last_integer
            todays_planets.add(orbit)
            if (planets @ orbit) = Void then
                set_planet(create{PLANET}.make_standard (Current), orbit)
            end
            s.get_integer
            planets.item(orbit).set_size (s.last_integer + plsize_min)
            s.get_integer
            planets.item(orbit).set_climate (s.last_integer + climate_min)
            s.get_integer
            planets.item(orbit).set_mineral (s.last_integer + mnrl_min)
            s.get_integer
            planets.item(orbit).set_gravity (s.last_integer + grav_min)
            s.get_integer
            planets.item(orbit).set_type (s.last_integer + type_min)
            s.get_integer
            planets.item(orbit).set_special (s.last_integer + plspecial_min)
            pcount := pcount - 1
        end
        -- Remove stale planets
        from pcount := 1
        until pcount > Max_planets loop
            if planets.item(pcount) /= Void and not todays_planets.has(pcount) then
                planets.remove(pcount)
            end
            pcount := pcount + 1
        end
        changed.emit (Current)
    end

feature -- Redefined features

    add_fleet (f: like fleet_type) is
    do
        Precursor (f)
        changed.emit (Current)
    end

feature -- Accounting

    has_info: BOOLEAN
        -- Player has planet info

feature -- Signals

    changed: SIGNAL_1 [C_STAR]

feature {NONE} -- Internal

    fleet_type: C_FLEET

end -- class C_STAR
