class C_PLAYER_LIST
    -- Public status of the server (client view)

inherit
    PLAYER_LIST [C_PLAYER]
    undefine
        add
    redefine
        make
    end
    SUBSCRIBER
    MODEL
    IDMAP_ACCESS

creation
    make

feature -- Creation

    make is
    do
        Precursor
        make_model
    end

feature {SERVICE_PROVIDER} -- Subscriber callback

    on_message (msg: STRING; provider: SERVICE_PROVIDER; service: STRING) is
        -- Action when `msg' arrives from `provider''s `service'
    local
        newmsg: STRING
        new_items: DICTIONARY [C_PLAYER, STRING]
        left: INTEGER

        name: STRING
        pid: reference INTEGER
        p: C_PLAYER
        s: SERIALIZER
        ir: INTEGER_REF
    do
        newmsg := msg

        s.unserialize ("i", newmsg)
        ir ?= s.unserialized_form @ 1; left := ir.item
        newmsg := newmsg.substring (s.used_serial_count+1, newmsg.count)

--FIXME: make in-place instead of creating a new list
        !!new_items.make
        from until left = 0 loop
            -- Get name
            s.unserialize ("is", newmsg)
            pid ?= s.unserialized_form @ 1
            name ?= s.unserialized_form @ 2
            if idmap.has (pid) then
                p ?= idmap @ pid
                    check p /= Void end
            else
                !!p.make (name)
                idmap.add (p, pid)
            end
            new_items.add (p, name)
            p.unserialize_from (newmsg)
            left := left - 1
        end
        items := new_items

        notify_views
    end

end -- class C_PLAYER_LIST