class COLONY_NAME_VIEW
    -- ews view for current stardate

inherit
    WINDOW
    rename make as window_make end

creation
    make

feature -- Representation

   colony: C_COLONY

feature {NONE} -- Creation

    make (w:WINDOW; where: RECTANGLE) is
        -- build widget without a model
    local
        r: RECTANGLE
    do
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

    set_colony(c: C_COLONY) is
    do
        if colony /= Void then
            colony.changed.disconnect(agent update_name)
        end
        colony := c
        colony.changed.connect(agent update_name)
        update_name
    end

feature {NONE} -- Widgets

    label: LABEL

end -- class COLONY_NAME_VIEW