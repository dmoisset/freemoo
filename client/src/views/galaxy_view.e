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
        a: FMA_FRAMESET
        i, j: INTEGER
    do
        zoom := 3
        set_model (new_model)
        window_make(w, where)
        !!a.make ("client/galaxy-view/background.fma")
        background := a.images @ 1
        !!pics.make(kind_min, kind_max, stsize_min, stsize_max + 3)
        from i := kind_min
        until i > kind_max loop
            from j := stsize_min
            until j > stsize_max + 3 loop
                pics.put(create{ANIMATION_FMA_TRANSPARENT}.make("client/galaxy-view/star" +
                 (i - kind_min).to_string + (j - stsize_min).to_string + ".fma"), i, j)
                j := j + 1
            end
            i := i + 1
        end
        make_projs
        -- Update gui
        on_model_change
    end

feature -- Access, some will be moved to internal.
    background: IMAGE

    is_inside: BOOLEAN
        --True while mouse cursor is inside my window

    star_window: WINDOW
        -- Window used to display a system, Void if none is being shown

    fleet_window: WINDOW
        -- Window used to display a fleet, Void if none is being shown

    pics: ARRAY2[ANIMATION_FMA_TRANSPARENT]


feature {NONE} -- Internal

    projs: ARRAY[PARAMETRIZED_PROJECTION]

    zoom: INTEGER
        -- Zoom level

feature -- Redefined features

    on_model_change is
        -- Update gui
    local
        i: ITERATOR[C_STAR]
        ic: ITERATOR[WINDOW]
        ww: WINDOW
        a: ANIMATION
    do
        from ic := children.get_new_iterator until ic.is_off loop
            remove_child(ic.item)
        end
            check children.is_empty end
        from i := model.stars.get_new_iterator until i.is_off loop
            if i.item.kind = i.item.kind_blackhole then -- zoom not implemented yet
                projs.item(zoom).project(i.item)
                if (projs.item(zoom).x >= 0) and (projs.item(zoom).y >= 0) then
                    a := pics.item(i.item.kind, i.item.size + zoom)
                    !WINDOW_ANIMATED!ww.make (Current,
                        (projs.item(zoom).x - a.width / 2).rounded,
                        (projs.item(zoom).y - a.height / 2).rounded, a)
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
        img: IMAGE
    do
        show_image (create {SDL_SOLID_IMAGE}.make (r.width, r.height, 0, 0, 0),
                    r.x, r.y, r)
        show_image(background, 0, 0, r)
        Precursor (r)
        from i := model.stars.get_new_iterator
        until i.is_off loop
            if i.item.kind /= i.item.kind_blackhole then
                projs.item(zoom).project(i.item)
                img := pics.item(i.item.kind, i.item.size + zoom).item
                show_image (img, (projs.item(zoom).x - img.width / 2).rounded,
                            (projs.item(zoom).y - img.height / 2).rounded, r)
            end
            i.next
        end
    end


    handle_event (event: EVENT) is
    local
        n: EVENT_MOUSE_NOTIFY
        m: EVENT_MOUSE_MOVE
        b: EVENT_MOUSE_BUTTON
        p: PARAMETRIZED_PROJECTION
        i: ITERATOR[C_STAR]
        r: RECTANGLE
        s: STAR_VIEW
        found: BOOLEAN
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
                if b.button = 1 and not b.state then
                    event.set_handled
                    from i := model.stars.get_new_iterator
                    until i.is_off or found loop
                        projs.item(zoom).project(i.item)
                        if (projs.item(zoom).x - b.x).abs < 4 + 2 * zoom and (projs.item(zoom).y - b.y).abs < 3 then
                            r.set_with_size (40, 40, 347, 273)
                            !!s.make (parent, r, i.item)
                            found := True
                        end
                        i.next
                    end
                elseif b.button = 3 and not b.state then
                    event.set_handled
                    p := projs.item(zoom).twin
                    p.translate(-p.dx, -p.dy)
                    p.project(model.limit)
                    projs.item(zoom).translate(location.width // 2 - b.x, location.height // 2 - b.y)
                    if projs.item(zoom).dx > gborder then
                        projs.item(zoom).set_translation(gborder, projs.item(zoom).dy)
                    elseif projs.item(zoom).dx < location.width - p.x - gborder then
                        projs.item(zoom).set_translation(location.width - p.x - gborder, projs.item(zoom).dy)
                    end
                    if projs.item(zoom).dy > gborder then
                        projs.item(zoom).set_translation(projs.item(zoom).dx, gborder)
                    elseif projs.item(zoom).dy < location.height - p.y - gborder then
                        projs.item(zoom).set_translation(projs.item(zoom).dx, location.height - p.y - gborder)
                    end
                    on_model_change
                end
            end
        end
    end

feature {NONE} -- Internal configuration and constants

    gborder: INTEGER is 20
        -- pixels allowed around galaxy

    make_projs is
    do
        !!projs.make(0, 3)
        projs.put(create {PARAMETRIZED_PROJECTION}.make_simple(12.31578, 13.40740, gborder, gborder), 0)
        projs.put(create {PARAMETRIZED_PROJECTION}.make_simple(24.63156, 26.81480, gborder, gborder), 1)
        projs.put(create {PARAMETRIZED_PROJECTION}.make_simple(36.94734, 40.22220, gborder, gborder), 2)
        projs.put(create {PARAMETRIZED_PROJECTION}.make_simple(49.26312, 53.62960, gborder, gborder), 3)
    end

invariant

    zoom.in_range (0, 3)

end -- GALAXY_VIEW