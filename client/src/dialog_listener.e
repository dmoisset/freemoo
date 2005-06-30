class DIALOG_LISTENER

inherit
    SUBSCRIBER

create
    make

feature {NONE} -- Creation

    make is
    do
        create on_dialog_addition.make
        create on_dialog_removal.make
    end

feature -- Signals

    on_dialog_addition: SIGNAL_1 [TUPLE[INTEGER, INTEGER, STRING]]
        -- arguments: id, kind, info
    
    on_dialog_removal: SIGNAL_1 [INTEGER]
        -- arguments: id

feature -- Redefined features

    on_message (msg: STRING; provider: SERVICE_PROVIDER; service: STRING) is
    local
        u: UNSERIALIZER
        id, kind: INTEGER
        count: INTEGER
    do
        create u.start (msg)
        u.get_integer -- action
        inspect u.last_integer
        when dialog_remove then
            u.get_integer -- id
            on_dialog_removal.emit (u.last_integer)
        when dialog_add then
            u.get_integer -- id
            id := u.last_integer
            u.get_integer -- kind
            kind := u.last_integer
            u.get_string
            on_dialog_addition.emit ([id, kind, u.last_string])
        when dialog_list then
            u.get_integer
            count := u.last_integer
            from until count = 0 loop
                u.get_integer -- id
                id := u.last_integer
                u.get_integer -- kind
                kind := u.last_integer
                u.get_string
                on_dialog_addition.emit ([id, kind, u.last_string])
                count := count - 1
            end
        else
            print ("DIALOG_LISTENER: invalid message received.%N")
        end
    end

feature {NONE} -- Internals

    dialog_remove: INTEGER is 0
    dialog_add: INTEGER is 1
    dialog_list: INTEGER is 2
-- FIXME: this is duplicated on the server, S_GAME

end -- class DIALOG_LISTENER