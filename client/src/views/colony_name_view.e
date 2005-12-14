class COLONY_NAME_VIEW
    -- Shows a colony's name

inherit
    COLONY_VIEW

creation
    make

feature {NONE} -- Creation

    make (w:WINDOW; where: RECTANGLE) is
        -- build widget without a model
    local
        r: RECTANGLE
    do
        my_connect_identifier := agent update_name
        window_make(w, where)
        r.set_with_size(0, 0, location.width, location.height)
        !!label.make (Current, r, "")
        label.set_h_alignment(label.horz_align_left)
        label.set_v_alignment(label.vert_align_center)
    end

feature -- Redefined features

    update_name is
        -- Update gui
    require
        colony /= Void
    local
        s: STRING
    do
        s := "Colony on " + colony.location.name
        label.set_text (s)
    end

feature {NONE} -- Widgets

    label: LABEL

end -- class COLONY_NAME_VIEW
