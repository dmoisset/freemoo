class CONNECTION_INDICATOR

inherit
    WINDOW
    redefine make end

creation make

feature {NONE} -- Creation

    make (w: WINDOW; where: RECTANGLE) is
    local
        r: RECTANGLE
    do
        index := items.lower
        Precursor (w, where)
        r := location
        r.move_to (0, 0)
        !!label.make (Current, r, " ")
    end

feature -- Access

    active: BOOLEAN
        -- True iff the indicator is active

feature -- Operations

    activate is
    do
        active := True
        index := items.lower+1
        update
    ensure
        active
    end

    deactivate is
    do
        active := False
        index := items.lower
        update
    ensure
        not active
    end

    activity is
    require
        active
    do
        index := index + 1
        if index > items.upper then index := items.lower+1 end
        update
    end

feature {NONE} -- Representation

    label: LABEL

    index: INTEGER

    items: ARRAY [STRING] is
    once
        Result := <<" ",
                    "**   ",
                    " **  ",
                    "  ** ",
                    "   **",
                    "  ** ",
                    " **  "
                    >>
    end

    update is
    do
        label.set_text (items @ index)
    end

invariant
    items.valid_index (index)

end -- class CONNECTION_INDICATOR