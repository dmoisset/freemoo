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
        r: RECTANGLE
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
        background ?= a.images @ 1
        !!pics.make (kind_min, kind_max, stsize_min, stsize_max + 3)
        r.set_with_size (0, 0, width, height)
        !!blackholes_window.make (Current, r)
        !!bh_windows.make (1, 0)
        !!bh_anims.make (stsize_min, stsize_max + 3)
        font := create {BITMAP_FONT_FMI}.make ("client/galaxy-view/font2.fmi")

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
        make_projs
        get_limits
        refresh
        dirty := True
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
    do
        get_limits
        -- Note: This assumes projections w/o rotations
        if limit_x > 0 and limit_y > 0 and projs.valid_index (zoom) then
            current_projection.translate (-x, -y)
            posx := -current_projection.dx / limit_x
            posy := -current_projection.dy / limit_y
            zoom := value
            get_limits
            current_projection.set_translation (-posx*limit_x, -posy*limit_y)
            current_projection.translate (x, y)
            normalize_position
            dirty := True
            refresh
        end
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

feature -- Redefined features

    on_model_change is
        -- Update gui
    do
        if model.changed_starlist then
            make_projs
            get_limits
            refresh
        else
            request_redraw_all
        end
        dirty := True
    end

    refresh is
        -- Regenerate cache, put blackhole animations
    local
        i: ITERATOR[C_STAR]
    do
        remove_blackholes
        -- Add blackholes
        from i := model.stars.get_new_iterator_on_items
        until i.is_off loop
            if i.item.kind = i.item.kind_blackhole then
                draw_blackhole (i.item)
            end
            i.next
        end
        request_redraw_all
    end

    redraw (area: RECTANGLE) is
    local
        i: ITERATOR[C_STAR]
    do
        if dirty then
            dirty := False
            -- Initialize cache
            !!cache.make (width, height)
            background.blit_fast (cache, 0, 0)
            from i := model.stars.get_new_iterator_on_items
            until i.is_off loop
                if i.item.kind /= i.item.kind_blackhole then
                    draw_star (i.item)
                end
                i.next
            end
        end
        show_image(cache, 0, 0, area)
        Precursor (area)
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
                else do_nothing
                end
            end
        end
    end

feature {NONE} -- Redrawing

    remove_blackholes is
    local
        ic: ITERATOR[WINDOW]
    do
        from ic := bh_windows.get_new_iterator until ic.is_off loop
            ic.item.remove
            ic.next
        end
        bh_windows.clear
    end

    draw_star (s: C_STAR) is
    local
        img: SDL_IMAGE -- star image
        px, py: REAL -- projected star
        lx, ly: INTEGER -- star label position
        lwidth: INTEGER -- star label width
        r: RECTANGLE
    do
        current_projection.project(s)
        px := current_projection.x
        py := current_projection.y
        img ?= pics.item(s.kind, s.size + zoom)
        img.blit_fast (cache, (px - img.width / 2).rounded,
                              (py - img.height / 2).rounded)
        if s.has_info then
            lwidth := font.width_of (s.name)
            lx := (px - lwidth / 2).rounded
            ly := label_offset+(py - font.height / 2).rounded
            if lx < width and ly < height then
                font.show_at(cache, lx, ly, s.name)
                r.set_with_size(lx - 1, ly, lwidth, font.height)
                paint (r, s)
            end
        end
    end

    draw_blackhole (s: STAR) is
    local
        ww: WINDOW -- blackhole window
        a: ANIMATION -- blackhole animation
    do
        current_projection.project(s)
        if (current_projection.x >= 0) and (current_projection.y >= 0) then
            a := clone (bh_anims @ (s.size + zoom))
            !WINDOW_ANIMATED!ww.make (blackholes_window,
                (current_projection.x - a.width / 2).rounded,
                (current_projection.y - a.height / 2).rounded,
                a)
            bh_windows.add_last (ww)
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
        from i := model.stars.get_new_iterator_on_items
        until i.is_off or found loop
            current_projection.project(i.item)
            if (current_projection.x - x).abs < 4 + 2 * (zoom + i.item.size - i.item.stsize_min)
            and (current_projection.y - y).abs < 4 + 2 * (zoom + i.item.size - i.item.stsize_min)
            and i.item.kind /= i.item.kind_blackhole then
                if star_window /= Void and then children.fast_has(star_window) then
                    r := star_window.location
                    star_window.remove
                else
                    if x > width / 2 then
                        if y > height / 2 then
                            r.set_with_size (10, 10, 347, 273)
                        else
                            r.set_with_size (10, (height - 283).max(10), 347, 273)
                        end
                    else
                        if y > height / 2 then
                            r.set_with_size ((width - 357).max(10), 10, 347, 273)
                        else
                            r.set_with_size ((width - 357).max(10), (height - 283).max(10), 347, 273)
                        end
                    end
                end
                !STAR_VIEW!star_window.make (Current, r, i.item)
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
        dirty := True
    end

    normalize_position is
        -- Put scroll inside limits
    do
        current_projection.set_translation (
            current_projection.dx.min (gborder).max (width - limit_x - gborder),
            current_projection.dy.min (gborder).max (height - limit_y - gborder))
    end

feature {NONE} -- Internal

    projs: ARRAY [PARAMETRIZED_PROJECTION]
        -- Projections for different zoom levels

    current_projection: PARAMETRIZED_PROJECTION is
        -- Projection for current zoom level
    do
        Result := projs @ zoom
    end

    get_limits is
        -- Set `limit_x' and `limit_y'
    local
        p: PARAMETRIZED_PROJECTION
    do
        p := current_projection.twin
        p.set_translation (0, 0)
        p.project (model.limit)
        limit_x := p.x
        limit_y := p.y
    end

    limit_x, limit_y: REAL
        -- Projected galaxy limit

    background: SDL_IMAGE
        -- View background

    dirty: BOOLEAN
    cache: SDL_IMAGE
        -- View cache.

    star_window: WINDOW
        -- Window used to display a system

    fleet_window: WINDOW
        -- Window used to display a fleet

    blackholes_window: WINDOW
        -- Window for the blackholes

    bh_windows: ARRAY [WINDOW]
        -- List of blackhole windows

    bh_anims: ARRAY [ANIMATION_FMA_TRANSPARENT]
        -- Animations for the blackholes

    pics: ARRAY2[IMAGE]
        -- Pictures for the stars

    font: SDL_BITMAP_FONT

    pals: ARRAY[ARRAY[INTEGER]] is
    do
        !!Result.make(0, 8)
        Result.put(<<63488, 63488, 63488, 63488, 63488, 63488, 63488>>, 0)
        Result.put(<<50624, 50624, 50624, 50624, 50624, 50624, 50624>>, 1)
        Result.put(<<2881, 2881, 2881, 2881, 59196, 2881, 2881>>, 2)
        Result.put(<<59196, 59196, 59196, 59196, 59196, 59196, 59196>>, 3)
        Result.put(<<20827, 20827, 20827, 20827, 59196, 20827, 20827>>, 4)
        Result.put(<<43946, 43946, 43946, 43946, 43946, 43946, 43946>>, 5)
        Result.put(<<35503, 35503, 35503, 35503, 35503, 35503, 35503>>, 6)
        Result.put(<<64576, 64576, 64576, 64576, 64576, 64576, 64576>>, 7)
        Result.put(<<33808, 33808, 33808, 33808, 33808, 33808, 33808>>, 8)
    end

    paint(r: RECTANGLE; star: STAR) is
        -- Colorizes `cache' within `r' according to colonies on `star'
    local
        i, total, partial, fraction: INTEGER
        partial_r: RECTANGLE
    do
        -- Count howmany Colonies there are
        from i := 1
        until i > 5 loop
            if star.planets.item(i) /= Void and then star.planets.item(i).colony /= Void then
                total := total + 1
            end
            i := i + 1
        end
        if total = 0 then
            cache.colorize (r, pals @ 8)
        else
            fraction := (r.width / total).ceiling
            from i := 1
            until i > 5 loop
                if star.planets.item(i) /= Void and then star.planets.item(i).colony /= Void then
                    partial_r.set_with_size(r.x + partial, r.y, fraction, r.height)
                    cache.colorize (partial_r, pals@ (star.planets.item(i).colony.owner.color))
                    partial := partial + fraction
                end
                i := i + 1
            end
        end
    end

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