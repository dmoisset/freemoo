class DATE_VIEW
    -- ews view for current stardate

inherit
    WINDOW
    rename make as window_make end

creation
    make

feature {NONE} -- Representation

   status: C_GAME_STATUS

feature {NONE} -- Creation

    make (w:WINDOW; where: RECTANGLE; new_status: C_GAME_STATUS) is
        -- build widget as view of `new_status'
    local
        r: RECTANGLE
    do
        window_make(w, where)
        status := new_status
        status.changed.connect (agent update_date)
        r := location
        r.translate (-location.x, -location.y)
        !!label.make (Current, r, "")
        -- Update gui
        update_date
    end

feature -- Redefined features

    update_date is
        -- Update gui
    local
        s: STRING
    do
        s := (3500+(status.date // 10)).to_string
        s.extend ('.') ;
        (status.date \\ 10).append_in (s)

        label.set_text (s)
    end

feature {NONE} -- Widgets

    label: LABEL

end -- class DATE_VIEW