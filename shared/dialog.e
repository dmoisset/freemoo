deferred class DIALOG
    -- Abstract class representing interactions where the game requests
    -- some information and waits asynchronously for response(s).

feature -- Access

    id: INTEGER
        -- Unique id for this dialog (unique between the dialogs of `handler')

    handler: DIALOG_HANDLER [DIALOG]
        -- Connection owning this dialog

    kind: INTEGER is deferred end

    info: STRING is
        -- Information sent on dialog creation
    deferred
    ensure
        Result /= Void
    end

feature -- Operations

    set_handler (h: like handler; new_id: INTEGER) is
    require
        h /= Void
    do
        handler := h
        id := new_id
    ensure
        id = new_id
    end

    close is
    do
        handler.remove_dialog (Current)
    end

    on_message (message: STRING) is
        -- Handle `message'
    deferred
    end

end -- class DIALOG
