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
        -- To keep invariant while being added
        !!projs.make (0, 0)
        projs.put (create {PARAMETRIZED_PROJECTION}.make_identity, projs.lower)
        zoom := projs.lower
        -- Init view
        set_model (new_model)
        window_make (w, where)
        -- Load images
        !!a.make ("client/galaxy-view/background.fma")
        background := a.images @ 1
        !!pics.make (kind_min, kind_max, stsize_min, stsize_max + 3)
        !!bh_anims.make (stsize_min, stsize_max + 3)
        from j := stsize_min
        until j > stsize_max + 3 loop
            from i := kind_min
            until i > kind_max loop
                !!a.make ("client/galaxy-view/star" +
                 (i - kind_min).to_string + (j - stsize_min).to_string + ".fma")
                pics.put(a.images @ 1, i, j)
                i := i + 1
            end
            bh_anims.put(create{ANIMATION_FMA_TRANSPARENT}.make("client/galaxy-view/star" +
                 (kind_blackhole - kind_min).to_string + (j - stsize_min).to_string + ".fma"), j)
            j := j + 1
        end
        -- Update gui
        on_model_change
        set_zoom (0, width//2, height//2)
    end

feature -- Access

    zoom: INTEGER
        -- Zoom level

feature -- Operations

    set_zoom (value: INTEGER; x, y: INTEGER) is
        -- Change the zoom level to `value', fixed point on (`x', `y')
    local
        posx, posy: REAL
        p: PARAMETRIZED_PROJECTION
    do
        p := current_projection.twin
        p.set_translation (0, 0)
        p.project (model.limit)
        -- Note: This assumes projections w/o rotations
        if p.x > 0 and p.y > 0 and projs.valid_index (zoom) then
            current_projection.translate (-x, -y)
            posx := -current_projection.dx / p.x
            posy := -current_projection.dy / p.y
                check posx.in_range (0, 1) and posy.in_range (0, 1) end
            zoom := value
            p := current_projection.twin
            p.set_translation (0, 0)
            p.project (model.limit)
            current_projection.set_translation (-posx*p.x, -posy*p.y)
            current_projection.translate (x, y)
            normalize_position
            refresh
        end
    end

feature -- Redefined features

    on_model_change is
        -- Update gui
    do
        make_projs
        refresh
    end

    refresh is
    local
        i: ITERATOR[C_STAR]
        ic: ITERATOR[WINDOW]
        ww: WINDOW
        a: ANIMATION
    do
-- Should only remove blackholes
        from ic := children.get_new_iterator until ic.is_off loop
            remove_child(ic.item)
        end
            check children.is_empty end
        from i := model.stars.get_new_iterator until i.is_off loop
            if i.item.kind = i.item.kind_blackhole then
                current_projection.project(i.item)
                if (current_projection.x >= 0) and (current_projection.y >= 0) then
                    a := clone (bh_anims @ (i.item.size + zoom))
                    !WINDOW_ANIMATED!ww.make (Current,
                        (current_projection.x - a.width / 2).rounded,
                        (current_projection.y - a.height / 2).rounded,
                        a)
                    children.add_last(ww)
                end
            end
            i.next
        end
        request_redraw_all
    end

    redraw (area: RECTANGLE) is
    local
        i: ITERATOR[C_STAR]
        px, py: REAL
        img: IMAGE
    do
        show_image (create {SDL_SOLID_IMAGE}.make (area.width, area.height, 0, 0, 0),
                    area.x, area.y, area)
        show_image(background, 0, 0, area)
-- Perhaps cache this?
        Precursor (area)
        from i := model.stars.get_new_iterator
        until i.is_off loop
            if i.item.kind /= i.item.kind_blackhole then
                current_projection.project(i.item)
                px := current_projection.x
                py := current_projection.y
                img := pics.item(i.item.kind, i.item.size + zoom)
                show_image (img, (px - img.width / 2).rounded,
                            (py - img.height / 2).rounded, area)
-- has_been_visited must be renamed
                if i.item.has_been_visited then
-- Should have a font here
                    img := display.default_font.show (i.item.name)
                    show_image (img,
                                (px - img.width / 2).rounded,
                                label_offset+(py - img.height / 2).rounded,
                                area)
                end
            end
            i.next
        end
    end

    handle_event (event: EVENT) is
    local
        b: EVENT_MOUSE_BUTTON
    do
        Precursor (event)
        if not event.handled then
            b ?= event
            if b /= Void and then not b.state then
                event.set_handled
                inspect
                    b.button
                when 1 then on_left_click (b.x, b.y)
                when 3 then center_on (b.x, b.y)
                when 4 then zoom_in (b.x, b.y)
                when 5 then zoom_out (b.x, b.y)
                end
            end
        end
    end

feature {NONE} -- Event handlers

    on_left_click (x, y: INTEGER) is
        -- Click on view, try to open a fleet or star window
    local
        i: ITERATOR[C_STAR]
        found: BOOLEAN
        r: RECTANGLE
    do
        from i := model.stars.get_new_iterator
        until i.is_off or found loop
            current_projection.project(i.item)
            if (current_projection.x - x).abs < 4 + 2 * (zoom + i.item.size - i.item.stsize_min)
            and (current_projection.y - y).abs < 4 + 2 * (zoom + i.item.size - i.item.stsize_min)
            and i.item.kind /= i.item.kind_blackhole then
                r.set_with_size (40, 40, 347, 273)
-- Should be `Current', not `parent'
                if star_window /= Void and then parent.children.fast_has(star_window) then
                    parent.remove_child(star_window)
                end
                !STAR_VIEW!star_window.make (parent, r, i.item)
                found := True
            end
            i.next
        end
    end

    center_on (x, y: INTEGER) is
        -- Scroll to set center on `x', `y'
    do
        current_projection.translate (width // 2 - x, height // 2 - y)
        normalize_position
        refresh
    end

    normalize_position is
        -- Put scroll inside limits
    local
        p: PARAMETRIZED_PROJECTION
    do
        p := current_projection.twin
        p.set_translation (0, 0)
        p.project (model.limit)
        current_projection.set_translation (
            current_projection.dx.min (gborder).max (width - p.x - gborder),
            current_projection.dy.min (gborder).max (height - p.y - gborder))
    end

    zoom_in (x, y: INTEGER) is
        -- zoom in, with (`x',`y') as fixed point
    do
        if zoom < projs.upper then
            set_zoom (zoom+1, x, y)
        end
    end

    zoom_out (x, y: INTEGER) is
        -- zoom out, with (`x',`y') as fixed point
    do
        if zoom > projs.lower then
            set_zoom (zoom-1, x, y)
        end
    end

feature {NONE} -- Internal

    projs: ARRAY [PARAMETRIZED_PROJECTION]
        -- Projections for different zoom levels

    current_projection: PARAMETRIZED_PROJECTION is
        -- Projection for current zoom level
    do
        Result := projs @ zoom
    end

    background: IMAGE
        -- View background

    star_window: WINDOW
        -- Window used to display a system

    fleet_window: WINDOW
        -- Window used to display a fleet

    bh_anims: ARRAY [ANIMATION_FMA_TRANSPARENT]
        -- Animations for the blackholes

    pics: ARRAY2[IMAGE]
        -- Pictures for the stars

feature {NONE} -- Internal configuration and constants

    gborder: INTEGER is 20
        -- pixels allowed around galaxy

    label_offset: INTEGER is 20
        -- pixels between star center and star name label center

    make_projs is
        -- Make diferent zoom.
        -- Zoom levels in progression 6 4 3 2
    local
        p: PARAMETRIZED_PROJECTION
    do
-- Make this work right for non huge galaxies
        !!projs.make(0, 3)
        !!p.make_identity
        p.project (model.limit)
        !!p.make_simple ((width-2*gborder)/p.x, (height-2*gborder)/p.y, gborder, gborder)
        projs.put(p, 0)
        p := p.twin
        p.scale ((6/4).to_real, (6/4).to_real)
        projs.put(p, 1)
        p := p.twin
        p.scale ((4/3).to_real, (4/3).to_real)
        projs.put(p, 2)
        p := p.twin
        p.scale ((3/2).to_real, (3/2).to_real)
        projs.put(p, 3)
    end

invariant
    projs.valid_index (zoom)
    current_projection /= Void

end -- GALAXY_VIEW