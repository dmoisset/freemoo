class GALAXY_VIEW
    -- ews view for a GALAXY

inherit
    VIEW [C_GALAXY]
    WINDOW
        rename make as window_make
        redefine handle_event, redraw end
    MAP_CONSTANTS

creation
    make

feature {NONE} -- Creation

    make (w:WINDOW; where: RECTANGLE; new_model: C_GALAXY) is
        -- build widget as view of `new_model'
    local
        a: ANIMATION
        i, j: INTEGER
    do
        set_model (new_model)
        window_make(w, where)
        !ANIMATION_FMA!a.make ("client/galaxy-view/background.fma")
        background := a.item
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
        !!p.make_identity
        p.scale(22, 22)
        p.translate(20, 20)
        -- Update gui
        on_model_change
    end

feature -- Access, some will be moved to internal.
    background: IMAGE

    p: PARAMETRIZED_PROJECTION

    is_inside: BOOLEAN
        --True while mouse cursor is inside `my_window'

    star_window: WINDOW
        -- Window used to display a system, Void if none is being shown

    fleet_window: WINDOW
        -- Window used to display a fleet, Void if none is being shown

    pics: ARRAY2[ANIMATION_FMA_TRANSPARENT]


feature -- Redefined features

    on_model_change is
        -- Update gui
    local
        i: ITERATOR[C_STAR]
        ic: ITERATOR[WINDOW]
        ww: WINDOW
    do
        from ic := children.get_new_iterator until ic.is_off loop
            remove_child(ic.item)
        end
            check children.is_empty end
        from i := model.stars.get_new_iterator until i.is_off loop
            if i.item.kind = i.item.kind_blackhole then -- zoom not implemented yet
                p.project(i.item)
                if (p.x >= 0) and (p.y >= 0) then
                    !WINDOW_ANIMATED!ww.make (Current, p.x.rounded, p.y.rounded, pics.item(i.item.kind, i.item.size))
                    children.add_last(ww)
                end
            end
            i.next
        end
        request_redraw_all
    end


    redraw(r: RECTANGLE) is
    local
        i: ITERATOR[C_STAR]
    do
        show_image (create {SDL_SOLID_IMAGE}.make (r.width, r.height, 0, 0, 0),
                    r.x, r.y, r)
        show_image(background, 0, 0, r)
        Precursor (r)
        from i := model.stars.get_new_iterator
        until i.is_off loop
            if i.item.kind /= i.item.kind_blackhole then
                p.project(i.item)
                    show_image (pics.item(i.item.kind, i.item.size).item, p.x.rounded, p.y.rounded, r)
            end
            i.next
        end
    end


    handle_event (event: EVENT) is
    local
        n: EVENT_MOUSE_NOTIFY
        m: EVENT_MOUSE_MOVE
        b: EVENT_MOUSE_BUTTON
    do
        Precursor (event)
        if not event.handled then
            m ?= event
            if m /= Void and is_inside then
            end
            n ?= event
            if n /= Void then
                if n.is_enter then
                    is_inside := True
                else
                    is_inside := False
                end
            end
            b ?= event
            if b /= Void then
                if b.button = 1 and b.state then
                    event.set_handled
                elseif b.button = 1 and not b.state then
                    event.set_handled
                elseif b.button = 3 and not b.state then
                    event.set_handled
                    p.translate(Current.width // 2 - b.x, Current.height // 2 - b.y)
                    on_model_change
                end
            end
        end
    end

end -- GALAXY_VIEW