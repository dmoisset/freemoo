class C_GALAXY
    -- Galactic map (client view)
    -- This model can have incomplete information, because server only sends
    -- what the player at the client should know.

inherit
    GALAXY
        redefine make, stars, set_stars end
    MODEL
        redefine notify_views end
    VIEW [C_STAR]
        rename on_model_change as on_star_change end
    SUBSCRIBER
    IDMAP_ACCESS

creation
    make

feature {NONE} -- Creation

    make is
    do
        Precursor
        make_model
    end

feature {SERVICE_PROVIDER} -- Subscriber callback

    on_message (msg: STRING; provider: SERVICE_PROVIDER; service: STRING) is
        -- Action whe `msg' arrives from `provider''s `service'
        -- Regenerates everything from scratch.  There must be a better way...
        -- Also, depend on stars not moving around in the array.
    local
        new_stars: DICTIONARY[C_STAR, INTEGER]
        new_fleets: DICTIONARY[FLEET, INTEGER]
        newmsg: STRING
        ir: reference INTEGER
        id, count, shipcount: INTEGER
        s: SERIALIZER
        owner: PLAYER
        fleet: FLEET
        star: C_STAR
        ship: SHIP
    do
        if service.is_equal("galaxy") then
            limit.unserialize_from(msg)
            s.unserialize("i", msg)
            ir ?= s.unserialized_form @ 1
            count := ir
            newmsg := msg
            newmsg.remove_first(s.used_serial_count)
            !!new_stars.make
            from until count = 0 loop
                s.unserialize("iii", newmsg)
                newmsg.remove_first(s.used_serial_count)
                ir ?= s.unserialized_form @ 1
                id := ir
                if idmap.has(id) then
                    star ?= idmap @ id
                else
                    !!star.make_defaults
                    star.add_view (Current)
                    idmap.put(star, id)
                end
                ir ?= s.unserialized_form @ 2
-- Using .item below because of SE bug #152
                star.set_kind(ir.item + star.kind_min)
                ir ?= s.unserialized_form @ 3
                star.set_size(ir.item + star.stsize_min)
                star.unserialize_from (newmsg)
                new_stars.add(star, id)
                count := count - 1
            end
            set_stars (new_stars)
        elseif service.has_suffix(":scanner") then
            s.unserialize("i", msg)
            ir ?= s.unserialized_form @ 1
            count := ir
            newmsg := msg.substring(s.used_serial_count + 1, newmsg.count)
            !!new_fleets.make
            from until count = 0 loop
                !!fleet.make
                s.unserialize("oioi", newmsg)
                newmsg.remove_first(s.used_serial_count)
                owner ?= s.unserialized_form @ 1
                fleet.set_owner(owner)
                ir ?= s.unserialized_form @ 2
                star ?= s.unserialized_form @ 3
                if ir = 0 then
                    fleet.set_orbit_center (star)
                else
                    fleet.set_destination (star)
                end
                fleet.set_eta(ir)
                fleet.unserialize_from(newmsg)
                new_fleets.add(fleet, count)
                ir ?= s.unserialized_form @ 4
                from shipcount := ir until shipcount = 0 loop
                    s.unserialize("ii", newmsg)
                    !!ship.make
                    ir ?= s.unserialized_form @ 1
                    ship.set_size(ir)
                    ir ?= s.unserialized_form @ 2
                    ship.set_picture(ir)
                    newmsg.remove_first(s.used_serial_count)
                    shipcount := shipcount - 1
                end
                count := count - 1
            end
            notify_views
        else
            check unexpected_message: False end
        end
    end

feature -- Redefined features

    stars: DICTIONARY [C_STAR, INTEGER]

    set_stars (starlist: DICTIONARY [C_STAR, INTEGER]) is
    require
        starlist /= Void
    do
        stars := starlist
        changed_starlist := True
        notify_views
    end

feature -- Redefined features

    on_star_change is
        -- Stars changed
    do
        changed_stardata := True
        notify_views
    end

feature -- Notification

    changed_starlist: BOOLEAN

    changed_stardata: BOOLEAN

    notify_views is
    do
        Precursor
        changed_starlist := False
        changed_stardata := False
    end

end -- class C_GALAXY