class DATE_VIEW
    -- ews view for current stardate

inherit
    VIEW [C_GAME_STATUS]
    WINDOW
    rename make as window_make end

creation
    make

feature {NONE} -- Creation

    make (w:WINDOW; where: RECTANGLE; new_model: C_GAME_STATUS) is
        -- build widget as view of `new_model'
    local
        r: RECTANGLE
    do
        window_make(w, where)
        set_model (new_model)
        r := location
        r.translate (-location.x, -location.y)
        !!label.make (Current, r, "")
        -- Update gui
        on_model_change
    end

feature -- Redefined features

    on_model_change is
        -- Update gui
    local
        s: STRING
    do
        s := (3500+(model.date // 10)).to_string
        s.extend ('.') ;
        (model.date \\ 10).append_in (s)

        label.set_text (s)
    end

feature {NONE} -- Widgets

    label: LABEL

end -- class DATE_VIEW