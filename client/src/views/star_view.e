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
    do
        window_make(w, where)
        set_model(new_model)
    end

feature -- Access

feature {NONE} -- Internal

    name_label: LABEL


feature -- redefined features

    on_model_change is
        -- Update gui
    do
    end

feature -- Redefined features
    redraw(r: RECTANGLE) is
    do
        show_image(background, 0, 0, r)
    end

feature -- Once pictures

    background: IMAGE is
    local
        a: FMA_FRAMESET
    once
        !!a.make("client/star-view/background.fma")
        Result := a.images@ 1
    end

end -- class STAR_VIEW