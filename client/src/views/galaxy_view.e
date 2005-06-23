class GALAXY_VIEW
    -- ews view for a GALAXY

inherit
    WINDOW
        rename make as window_make
        redefine handle_event, redraw end
    MAP_CONSTANTS

creation
    make

feature {NONE} -- Creation

    galaxy: C_GALAXY
        -- Model

    make (w:WINDOW; where: RECTANGLE; new_galaxy: C_GALAXY) is
        -- build widget as view of `new_model'
    local
        a: FMA_FRAMESET
        r: RECTANGLE
    do
        -- To keep invariant while being added
        !!projs.make (0, 0)
        projs.put (create {PARAMETRIZED_PROJECTION}.make_identity, projs.lower)
        zoom := projs.lower
        -- Init view
        galaxy := new_galaxy
        galaxy.fleets_change.connect (agent on_fleets_change)
        galaxy.star_change.connect (agent on_star_change)
        galaxy.map_change.connect (agent on_map_change)
        
        window_make (w, where)
        -- Load images
        !!a.make ("client/galaxy-view/background.fma")
        background ?= a.images @ 1
        r.set_with_size (0, 0, width, height)
        -- Blackholes' window
        !!blackholes_window.make (Current, r)
        -- Array of blackhole windows
        !!bh_windows.make (1, 0)
        font := create {BITMAP_FONT_FMI}.make ("client/galaxy-view/font2.fmi")
        -- Hotspots
        !!fleet_hotspots.make
        !!star_hotspots.make
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
        cancel_trajectory_selection
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

feature {NONE} -- Signal handlers

    on_map_change (g: C_GALAXY) is
    require
        g = galaxy
    do
        if oldlimit = Void or else galaxy.limit |-| oldlimit > 0 then
            oldlimit := galaxy.limit.twin
            make_projs
            get_limits
        end
        refresh
        dirty := True
    end

    on_fleets_change (g: C_GALAXY) is
        -- Update gui
    do
        request_redraw_all
        dirty := True
    end

    on_star_change (s: C_STAR) is
        -- Update gui
    do
        request_redraw_all
        dirty := True
    end

feature -- Redefined features

    refresh is
        -- Regenerate cache, put blackhole animations
    local
        i: ITERATOR[C_STAR]
    do
        remove_blackholes
        -- Add blackholes
        from i := galaxy.get_new_iterator_on_stars
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
        star_it: ITERATOR[C_STAR]
        fleet_it: ITERATOR[FLEET]
    do
        if dirty then
            dirty := False
            -- Initialize cache
            !!cache.make (width, height)
            -- Initialize hotspots
            background.show (cache, 0, 0)
            star_hotspots.clear
            from star_it := galaxy.get_new_iterator_on_stars
            until star_it.is_off loop
                if star_it.item.kind /= star_it.item.kind_blackhole then
                    draw_star (star_it.item)
                end
                star_it.next
            end
            fleet_hotspots.clear
            from fleet_it := galaxy.get_new_iterator_on_fleets
            until fleet_it.is_off loop
                draw_fleet (fleet_it.item)
                fleet_it.next
            end
        end
        show_image(cache, 0, 0, area)
        Precursor (area)
    end

    handle_event (event: EVENT) is
    local
        b: EVENT_MOUSE_BUTTON
        m: EVENT_MOUSE_MOVE
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
            else
                m ?= event
                if m /= Void and then fleet_window /= Void and then fleet_window.visible and then fleet_window.some_ships_selected  then
                    check_fleet_trajectory(m.x, m.y)
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
        img: IMAGE -- star image
        px, py: REAL -- projected star
        lx, ly: INTEGER -- star label position
        lwidth: INTEGER -- star label width
        r: RECTANGLE
        text: STRING
    do
        current_projection.project(s)
        px := current_projection.x
        py := current_projection.y
        img := star_pics.item(s.kind, s.size + zoom)
        r.set_with_size ((px - img.width / 2).rounded,
                    (py - img.height / 2).rounded, img.width, img.height)
        star_hotspots.add (r, s.id)
        img.show (cache, r.x, r.y)
        if galaxy.server.player.has_visited_star.has(s) then
            text := s.name
        elseif galaxy.server.player.knows_star.has(s) and s.has_info then
            text := "(" + s.name + ")"
        end
        if text /= Void then
            lwidth := font.width_of (text)
            lx := (px - lwidth / 2).rounded
            ly := label_offset+(py - font.height / 2).rounded
            if lx < width and ly < height then
                font.show_at(cache, lx, ly, text)
                r.set_with_size(lx - 1, ly, lwidth, font.height)
                paint (r, s)
            end
        end
    end

    draw_fleet (f: FLEET) is
    local
        img: IMAGE -- fleet image
        px, py: INTEGER -- projected fleet
        dx, pos: INTEGER -- offsetting
        r: RECTANGLE
        traj: TRAJECTORY
    do
        current_projection.project(f)
        img := fleet_pics.item(f.owner.color, zoom)
        px := (current_projection.x - img.width / 2).rounded
        py := (current_projection.y - img.height / 2).rounded
        if f.orbit_center /= Void then
            if f.destination = Void then dx := 1 else dx := -1 end
            from
                pos := fleet_offsets_x.lower
                r.set_with_size(px + dx * fleet_offset_size@zoom * fleet_offsets_x@pos, py - fleet_offset_size@zoom * fleet_offsets_y@pos, img.width, img.height)
            until
                pos = fleet_offsets_x.upper or fleet_hotspots.fast_occurrences(r) = 0
            loop
                pos := pos + 1
                r.set_with_size(px + dx * fleet_offset_size@zoom * fleet_offsets_x@pos, py - fleet_offset_size@zoom * fleet_offsets_y@pos, img.width, img.height)
            end
        else
            r.set_with_size (px, py, img.width, img.height)
        end
        fleet_hotspots.add (r, f.id)
        img.show(cache, r.x, r.y)

        if f.destination /= Void then
            !!traj.with_projection(f, f.destination, current_projection)
            if f.owner = galaxy.server.player then
                traj.set_type(traj.traj_type_normal)
            else
                traj.set_type(traj.traj_type_enemy)
            end
            traj.show(cache, traj.showx, traj.showy)
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

    cancel_trajectory_selection is
    do
        if trajectory_window /= Void then
        -- remove is broken, we have to hide trajectory_window as well
            trajectory_window.hide
            trajectory_window.remove
            trajectory_window := Void
        end
    end

    create_fleet_view(f: C_FLEET) is
    local
        r: RECTANGLE
    do
        if fleet_window /= Void and then children.fast_has(fleet_window) then
            r := fleet_window.location
            fleet_window.remove
            cancel_trajectory_selection
        else
            r.set_with_size(10, 10, fleet_window_width, fleet_window_height)
        end
        if star_window /= Void and then children.fast_has (star_window) then
            star_window.remove
        end
        !FLEET_VIEW!fleet_window.make(Current, r, f)
        fleet_window.set_cancel_trajectory_selection_callback(agent cancel_trajectory_selection)
        fleet_window.set_colonization_callback(agent select_planet_for_colonization)
    end

    select_planet_for_colonization is
    require
        fleet_window /= Void
        children.fast_has(fleet_window)
        fleet_window.fleet /= Void
        fleet_window.fleet.orbit_center /= Void
        fleet_window.fleet.can_colonize
        fleet_window.fleet.orbit_center.has_colonizable_planet
    local
        f: C_FLEET
        r: RECTANGLE
    do
        f := fleet_window.fleet
        fleet_window.remove
        cancel_trajectory_selection
        r.set_with_size((width - star_window_width) // 2,
                        (height - star_window_height) // 2,
                        star_window_width, star_window_height)
        create colonization_dialog.make(Current, r, f.orbit_center, galaxy.server.game_status, galaxy)
        colonization_dialog.set_selection_callback(agent colonize)
        colonization_dialog.set_fleet(f)
    end

    colonize(p: C_PLANET; f: C_FLEET) is
    do
        if p.type = p.type_planet then
            print("GALAXY_VIEW: Colonizing planet on orbit " + p.orbit.to_string + " with fleet " + f.id.to_string + "%N")
            colonization_dialog.remove
        end
    end

    on_left_click (x, y: INTEGER) is
        -- Click on view, try to open a fleet or star window
    local
        i: ITERATOR[RECTANGLE]
        r: RECTANGLE
        dest: STAR
    do
        i := star_hotspots.item_at_xy(x, y)
        if not i.is_off then
            if fleet_window /= Void and then fleet_window.visible and then fleet_window.some_ships_selected then
                dest := galaxy.star_with_id (star_hotspots.fast_key_at(i.item))
                if galaxy.server.player.is_in_range(dest) then
                    fleet_window.send_selection_to(dest)
                end
            else
                if star_window /= Void and then children.fast_has(star_window) then
                    r := star_window.location
                    star_window.remove
                else
                    r.set_with_size(x, y, star_window_width, star_window_height)
                    r := leave_visible(r)
                end
                if fleet_window /= Void and then children.fast_has(fleet_window) then
                    fleet_window.remove
                    cancel_trajectory_selection
                end
                !STAR_VIEW!star_window.make (Current, r,
                                             galaxy.star_with_id (star_hotspots.fast_key_at(i.item)),
                                             galaxy.server.game_status, galaxy)
                star_window.set_fleet_click_handler(agent create_fleet_view)
            end
        else
            i := fleet_hotspots.item_at_xy(x, y)
            if not i.is_off then
                create_fleet_view(galaxy.fleet_with_id (fleet_hotspots.fast_key_at(i.item)))
            end
        end
    end

    center_on (x, y: INTEGER) is
        -- Scroll to set center on `x', `y'
    do
        cancel_trajectory_selection
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

    check_fleet_trajectory (x, y: INTEGER) is
    local
        i: ITERATOR[RECTANGLE]
        traj: TRAJECTORY
        dest: STAR
    do
        i := star_hotspots.item_at_xy(x, y)
        if not i.is_off then
            if trajectory_window /= Void then
                trajectory_window.remove
            end
            dest := galaxy.star_with_id(star_hotspots.fast_key_at(i.item))
            !!traj.with_projection (dest, fleet_window.model_position, current_projection)
            if galaxy.exists_black_hole_between(fleet_window.fleet, dest) then
                traj.set_type(traj.traj_type_unreachable)
                fleet_window.set_info_black_hole
            elseif galaxy.server.player.is_in_range(dest) then
                traj.set_type(traj.traj_type_select_ok)
                fleet_window.set_info_eta(dest)
            else
                traj.set_type(traj.traj_type_unreachable)
                fleet_window.set_info_distance(dest)
            end
            !!trajectory_window.make(Current, traj.showx, traj.showy, traj)
            trajectory_window.send_behind(fleet_window)
        end
    end
    


feature {NONE} -- Internal functions

    traj_x, traj_y: INTEGER

    traj_image: SDL_LINE_IMAGE

    leave_visible(r: RECTANGLE): RECTANGLE is
        -- Return a rectangle with the same width and height of `r',
        -- but that if posible doesn't contain `r.x' and `r.y'
    do
        if r.x > width / 2 then
            if r.y > height / 2 then
                Result.set_with_size (10, 10, r.width, r.height)
            else
                Result.set_with_size (10, (height - r.height).max(10), r.width, r.height)
            end
        else
            if r.y > height / 2 then
                Result.set_with_size ((width - r.width).max(10), 10, r.width, r.height)
            else
                Result.set_with_size ((width - r.width).max(10), (height - r.height).max(10), r.width, r.height)
            end
        end
    end

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
        p.project (galaxy.limit)
        limit_x := p.x
        limit_y := p.y
    end

    pals: ARRAY[ARRAY[INTEGER]] is
    once
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
        total, partial, fraction: INTEGER
        partial_r: RECTANGLE
        i: ITERATOR [PLANET]
    do
        i := star.get_new_iterator_on_planets
        -- Count howmany Colonies there are
        from i.start until i.is_off loop
            if i.item /= Void and then i.item.colony /= Void then
                total := total + 1
            end
            i.next
        end
        if total = 0 then
            cache.colorize (r, pals @ 8)
        else
            fraction := (r.width / total).ceiling
            from i.start until i.is_off loop
                if i.item /= Void and then i.item.colony /= Void then
                    partial_r.set_with_size(r.x + partial, r.y, fraction, r.height)
                    cache.colorize (partial_r, pals @ (i.item.colony.owner.color))
                    partial := partial + fraction
                end
                i.next
            end
        end
    end

feature {NONE} -- Internal data

    star_hotspots: HOTSPOT_LIST
        -- Stars' hotspots, generated in redraw

    fleet_hotspots: HOTSPOT_LIST
        -- Fleets' hotspots, generated in redraw

    projs: ARRAY [PARAMETRIZED_PROJECTION]
        -- Projections for different zoom levels

    limit_x, limit_y: REAL
        -- Projected galaxy limit

    oldlimit: POSITIONAL
        -- Memorizes model's last limit, to not regenerate 
        -- projections unless necessary

    background: SDL_IMAGE
        -- View background

    dirty: BOOLEAN
    cache: SDL_IMAGE
        -- View cache.

    star_window: STAR_VIEW
        -- Window used to display a system

    fleet_window: FLEET_VIEW
        -- Window used to display a fleet

    colonization_dialog: PLANET_SELECTION_DIALOG

    trajectory_window: WINDOW_IMAGE
        -- Window used for doing fleet trajectory selection

    blackholes_window: WINDOW
        -- Window for the blackholes

    bh_windows: ARRAY [WINDOW]
        -- List of blackhole windows

    bh_anims: ARRAY [ANIMATION_FMA_TRANSPARENT] is
        -- Animations for the blackholes
    local j: INTEGER
    once
        !!Result.make (stsize_min, stsize_max + 3)
        from j := stsize_min
        until j > stsize_max + 3 loop
            Result.put(create{ANIMATION_FMA_TRANSPARENT}.make("client/galaxy-view/star" +
                 (kind_blackhole - kind_min).to_string + (j - stsize_min).to_string + ".fma"), j)
            j := j + 1
        end
    end

    star_pics: ARRAY2[IMAGE] is
        -- Pictures for the stars
    local
        i, j: INTEGER
        a: FMA_FRAMESET
    once
        !!Result.make (kind_min, kind_max, stsize_min, stsize_max + 3)
        from j := stsize_min
        until j > stsize_max + 3 loop
            from i := kind_min
            until i > kind_max loop
                !!a.make ("client/galaxy-view/star" +
                 (i - kind_min).to_string + (j - stsize_min).to_string + ".fma")
                Result.put(a.images @ 1, i, j)
                i := i + 1
            end
            j := j + 1
        end
    end

    fleet_pics: ARRAY2[IMAGE] is
        -- Pictures for fleets
    local
        i, j: INTEGER
        a: FMA_FRAMESET
    once
        check projs.lower = projs.upper - 3 end
        !!Result.make (0, 7, projs.lower, projs.upper)
        from i := 0
        until i > 7 loop
            from j := projs.lower
            until j > projs.upper loop
                !!a.make ("client/galaxy-view/fleet" +
                 i.to_string + (j - projs.lower).to_string + ".fma")
                Result.put(a.images @ 1, i, j)
                j := j + 1
            end
            i := i + 1
        end
    end

    font: SDL_BITMAP_FONT

feature {NONE} -- Internal configuration and constants

    gborder: INTEGER is 20
        -- pixels allowed around galaxy

    label_offset: INTEGER is 20
        -- pixels between star center and star name label center

    fleet_offset_size: ARRAY[INTEGER] is
        -- pixels fleets are offset from star center and one from 
        -- another
    once
        Result := <<2, 3, 4, 6>>
        Result.reindex(0)
    end

    fleet_offsets_x: ARRAY[INTEGER] is
    once
        Result := << 3, 5, 6, 7, 7, 7, 6, 5, 3, 1,
                     2, 4, 6, 7, 8, 9, 9, 9, 9, 9, 9, 9,
                     9, 8, 7, 6, 4, 2>>
    end

    fleet_offsets_y: ARRAY[INTEGER] is
    once
        Result := << 5,  4,  3,  2,  0, -2, -3, -4, -5, -5,
                     7,  7,  6,  5,  4,  3,  2,  1,  0, -1, -2, -3, -4,
                    -4, -5, -6, -7, -7>>
    end

    make_projs is
        -- Make diferent zoom.
        -- Zoom levels in progression 6 4 3 2
    local
        p: PARAMETRIZED_PROJECTION
    do
-- Make this work right for non huge galaxies
        !!projs.make(0, 3)
        !!p.make_identity
        p.project (galaxy.limit)
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

    star_window_width: INTEGER is 347
    star_window_height: INTEGER is 273
        -- Star Window's dimensions

    fleet_window_width: INTEGER is 217
    fleet_window_height: INTEGER is 275

invariant
    projs.valid_index (zoom)
    current_projection /= Void

end -- GALAXY_VIEW
