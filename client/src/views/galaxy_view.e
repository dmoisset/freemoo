class GALAXY_VIEW
    -- ews view for a GALAXY

inherit
    VIEW [C_GALAXY]
    WINDOW
        rename make as window_make
    MAP_CONSTANTS

creation
    make

feature {NONE} -- Creation

    make (w:WINDOW; where: RECTANGLE; new_model: C_GALAXY) is
        -- build widget as view of `new_model'
    local
        w1: WINDOW
        a: ANIMATION
        i, j: INTEGER
    do
        set_model (new_model)
        window_make(w, where)
        my_window := w
        !ANIMATION_FMA_TRANSPARENT!a.make ("client/galaxy-view/background.fma")
        !WINDOW_ANIMATED!w1.make (w, 0, 0, a)
        !!pics.make(kind_min, kind_max, stsize_min, stsize_max)
        from i := kind_min
        until i > kind_max loop
            from j := stsize_min
            until j > stsize_max loop
                pics.put(create{ANIMATION_FMA_TRANSPARENT}.make("client/galaxy-view/star" +
                 (i - kind_min).to_string + (j - stsize_min).to_string + ".fma"), i, j)
                j := j + 1
            end
            i := i + 1
        end
        -- Update gui
        on_model_change
    end

feature -- Redefined features

    on_model_change is
        -- Update gui
    local
        i: ITERATOR[C_STAR]
        p: PARAMETRIZED_PROJECTION
        ww: WINDOW
    do
        !!p.make_identity
        p.translate(30, 350)
        p.scale(15, 5)
        p.rotate(.7)
        from i := model.stars.get_new_iterator
        until i.is_off
        loop
            p.project(i.item)
            if i.item.kind = i.item.kind_blackhole then -- zoom not implemented yet
                !WINDOW_ANIMATED!ww.make (my_window, p.x.rounded, p.y.rounded, pics.item(i.item.kind, i.item.stsize_min))
            else
                !WINDOW_ANIMATED!ww.make (my_window, p.x.rounded, p.y.rounded, pics.item(i.item.kind, i.item.size))
            end
            i.next
        end
    end

    background: ANIMATION

    my_window: WINDOW

    pics: ARRAY2[ANIMATION_FMA_TRANSPARENT]

end -- GALAXY_VIEW