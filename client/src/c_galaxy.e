class C_GALAXY
    -- Galactic map (client view)
    -- This model can have incomplete information, because server only sends
    -- what the player at the client should know.

inherit
    GALAXY
        redefine
            make
    MODEL
    SUBSCRIBER

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
        new_stars: ARRAY[STAR]
        new_fleets: ARRAY[FLEET]
        new_msg: STRING
        ir: INTEGER_REF
        count: INTEGER
        s: SERIALIZER
    do
        if service_id = "galaxy" then
            s.unserialize("i", msg)
            ir ?= s.unserialized_form @ 1
            count := ir.item
            newmsg := msg.substring(s.used_serial_count + 1, newmsg.count)
            !!newstars.with_capacity (count,1)
            from until count = 0 loop
                s.unserialize("iii", newmsg)
                newmsg.remove_first(s.serial_used_count)
                ir ?= s.unserialized_form @ 1
                id := ir.item
                if stars.valid_index(id) and then (stars @ id) /= Void then
                    star := stars @ id
                else
                    !!star.make_defaults
                end
                ir ?= s.unserialized_form @ 2
                star.set_kind(ir.item)
                ir ?= s.unserialized_form @ 3
                star.set_size(ir.item)
                star.unserialize_from (newmsg)
                newstars.force(star, id)
                count := count - 1
            end
            stars := newstars
        elseif service_id.has_suffix(":scanner") then
            s.unserialize("i", msg)
            ir ?= s.unserialized_form @ 1
            count := ir.item
            newmsg := msg.substring(s.used_serial_count + 1, newmsg.count)
            !!newfleets.with_capacity (count,1)
            from until count = 0 loop
                s.unserialize("iiii", newmsg)
                -- d'oh!


end -- class C_GALAXY