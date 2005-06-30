class DIALOG_HANDLER [D -> DIALOG]

create
    make

feature {NONE} -- Creation

    make is
    do
        create dialogs.make
    end

feature -- Operations

    dialog_message (u: UNSERIALIZER) is
    local
        id: INTEGER
        data: STRING
    do
        u.get_integer
        id := u.last_integer
        u.get_string
        data := u.last_string
        if dialogs.has (id) then
            (dialogs @ id).on_message (data)
        else
            print ("dialog_message: message for invalid dialog.%N")
        end
    end

feature {DIALOG} -- Access

    has_dialog (d: D): BOOLEAN is
        -- Dialog `d' is active
    require
        d /= Void
    do
        Result := dialogs.has (d.id)
    end

feature {DIALOG} -- Operations

    add_dialog (d: D) is
        -- Make `d' receive dialog messages
    do
        last_dialog_id := last_dialog_id + 1
        d.set_handler (Current, last_dialog_id)
        dialogs.add (d, d.id)
    end

    remove_dialog (d: D) is
        -- Remove `d' from active dialog list
    require
        d /= Void
        has_dialog (d)
    do
        dialogs.remove (d.id)
    end

feature {NONE} -- Representation

    dialogs: DICTIONARY [D, INTEGER]
        -- Open dialogs, by id

    last_dialog_id: INTEGER
        -- biggest dialog id given

invariant
    dialogs /= Void
    
end -- class DIALOG_HANDLER