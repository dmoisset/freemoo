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
        new_items: DICTIONARY [C_PLAYER, STRING]
        left: INTEGER
        name: STRING
        pid: INTEGER
        p: C_PLAYER
        s: UNSERIALIZER
    do
        !!s.start (msg)
        s.get_integer; left := s.last_integer
--FIXME: make in-place instead of creating a new list
        !!new_items.make
        from until left = 0 loop
            -- Get name
            s.get_integer; pid := s.last_integer
            s.get_string; name := s.last_string
            if has (name) then
                p ?= Current @ name
                    check p /= Void and then p.id = pid end
            else
                !!p.make (name)
                p.set_id(pid)
            end
            new_items.add (p, name)
            p.unserialize_from (s)
            left := left - 1
        end
        items := new_items

        notify_views
    end

end -- class C_PLAYER_LIST