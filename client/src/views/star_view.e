class STAR_VIEW
    -- ews view for a STAR

inherit
    VIEW[C_STAR]
    WINDOW
        rename make as window_make
        redefine redraw end

creation
    make

feature {NONE} -- Creation

    make (w: WINDOW; where: RECTANGLE; new_model: C_STAR) is
        -- build widget as view of `new_model'
    local
        a: FMA_FRAMESET
        r: RECTANGLE
        i: INTEGER
        ww: WINDOW_IMAGE
    do
        window_make(w, where)
        set_model(new_model)
        -- Close Button
        !!a.make ("client/star-view/close-button.fma")
        !BUTTON_IMAGE!close_button.make (Current, 262, 235,
            a.images @ 1, a.images @ 1, a.images @ 2)
        close_button.set_click_handler (agent close)
        r.set_with_size (11, 13, 320, 28)
        if model.has_been_visited then
            !!name_label.make (Current, r, model.name)
            !!ww.make(Current, 157, 120, suns.item(model.kind - model.kind_min))
            from i := 1
            until i > 5 loop
                if model.planets.item(i) /= Void then
                    !!ww.make(Current, 29, 59, orbits.item(i))
                end
                i := i + 1
            end
        else
            !!name_label.make (Current, r, model.kind_names @ model.kind)
        end
    end


feature {NONE} -- Widgets

    close_button: BUTTON

    name_label: LABEL

feature {NONE} -- Callbacks

    close is
    do
        parent.remove_child(Current)
    end

feature -- redefined features

    on_model_change is
        -- Update gui
    do
        if model.has_been_visited then
            name_label.set_text(model.name)
        else
            name_label.set_text("Star")
        end
    end

feature -- Redefined features
    redraw(r: RECTANGLE) is
    local
    do
        show_image(background, 0, 0, r)
        Precursor(r)
    end

feature -- Once data

    background: IMAGE is
    local
        a: FMA_FRAMESET
    once
        !!a.make("client/star-view/background.fma")
        Result := a.images@ 1
    end

    orbits: ARRAY[IMAGE] is
    local
        i: INTEGER
        a: ANIMATION_FMA_TRANSPARENT
    once
        !!Result.make(1, 5)
        from i := 1
        until i > 5 loop
            !!a.make("client/star-view/orbit" + i.to_string + ".fma")
            Result.put(a.item, i)
            i := i + 1
        end
    end

    suns: ARRAY[IMAGE] is
    local
        i: INTEGER
        a: FMA_FRAMESET
    once
        !!Result.make(1, 6)
        from i := 1
        until i > 5 loop
            !!a.make("client/star-view/sun" + i.to_string + ".fma")
            Result.put(a.images @ 1, i)
            i := i + 1
        end
    end

end -- class STAR_VIEW