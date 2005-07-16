class STAR_VIEW
    -- ews view for a STAR

inherit
    MAP_CONSTANTS
    WINDOW
        rename make as window_make
        redefine redraw, handle_event, remove end

creation
    make

feature {NONE} -- Creation

    make (w: WINDOW; where: RECTANGLE; s: C_STAR; new_status: C_GAME_STATUS; g: C_GALAXY) is
        -- build widget as view of `s'
    require
        w /= Void
        s /= Void
        g /= Void
        new_status /= Void
    local
        a: FMA_FRAMESET
        r: RECTANGLE
        d: DRAG_HANDLE
    do
        window_make(w, where)
        -- Register on star
        star_changed_handler := agent star_changed
        star := s
        s.changed.connect (star_changed_handler)
        -- Register on status
        status_changed_handler := agent status_changed
        status := new_status
        status.changed.connect (status_changed_handler)
        -- Drag Handle
        r.set_with_size(0, 0, 347, 45)
        !!d.make(Current, r)
        -- Close Button
        !!a.make ("client/star-view/close-button.fma")
        !BUTTON_IMAGE!close_button.make (Current, 262, 235,
            a.images @ 1, a.images @ 1, a.images @ 2)
        close_button.set_click_handler (agent remove)
        -- Name label
        r.set_with_size (11, 13, 320, 28)
        !!name_label.make (Current, r, "")
        -- Planet label
        r.set_with_size (15, 50, 310, 100)
        !!planet_label.make (Current, r, "")
        -- Wormhole label
        r.set_with_size (209, 208, 120, 20)
        !!wormhole_label.make(Current, r, "")
        wormhole_label.set_h_alignment(1.0)

        !!removable_children.make(1, 0)
        -- Fleetsorbiting view
        make_fleets_orbiting(g)
        on_model_change
    end

    make_fleets_orbiting(g: C_GALAXY) is
    local
        r: RECTANGLE
    do
        r.set_with_size(20, 239, 170, 14)
        !!fleets_orbiting.make(Current, r, star, g)
    end

feature {NONE} -- Widgets

    close_button: BUTTON

    name_label: LABEL

    wormhole_label: LABEL

    planet_label: MULTILINE_LABEL

    fleets_orbiting: ORBITING_FLEETS_VIEW

feature {NONE} -- Callbacks

    enable_animations is
    do
        handle_ticks := False
    end

    disable_animations is
    do
        handle_ticks := True
    end

feature {NONE} -- Callbacks

    planet_click(p: C_PLANET) is
    do
        print ("Manage Colony on planet on orbit " + p.orbit.to_string + "%N")
    end

feature {NONE} -- Signal handlers

    star_changed_handler: PROCEDURE [ANY, TUPLE[C_STAR]]

    star_changed (s: C_STAR) is
    require
        s = star
    do
        on_model_change
    end

    status_changed_handler: PROCEDURE [ANY, TUPLE[C_GAME_STATUS]]

    status_changed (s: C_GAME_STATUS) is
    require
       s = status
    do
       if star.has_info then
           on_model_change
       end
    end

    on_model_change is
        -- Update gui
    require
        star /= Void
    local
        child: ITERATOR[WINDOW]
        wa: WINDOW_ANIMATED
        msg_label: MULTILINE_LABEL
        button: BUTTON_PLANET
        planet: C_PLANET
        ani: ANIMATION_FMA
        r: RECTANGLE
        tuple: TUPLE[INTEGER, INTEGER]
        ip: ITERATOR[C_PLANET]
    do
        -- Redraw cache on next redraw
        dirty := True
        -- Remove removable children
        from child := removable_children.get_new_iterator
        until child.is_off
        loop
            if children.fast_has(child.item) then
                child.item.remove
            end
            child.next
        end
        if star.has_info then
        -- Show info for an known system
            name_label.set_text("Star System " + star.name)
            if star.wormhole = Void then
                wormhole_label.set_text("")
            elseif star.wormhole.has_info then
                wormhole_label.set_text("Wormhole to " + star.wormhole.name)
            else
                wormhole_label.set_text("Active wormhole")
            end
            from
                ip := star.get_new_iterator_on_planets
            until ip.is_off loop
                planet := ip.item
                if planet /= Void and then planet.type /= type_asteroids then
                    if planet.type = type_gasgiant then
                        ani := gas_giant.twin
                    else
                        ani := planets.item (planet.climate, planet.size).twin
                    end
                    tuple := planet_pos(planet)
                    !!wa.make(Current, tuple.first - ani.width // 2,
                              tuple.second - ani.height // 2, ani)
                    removable_children.add_last(wa)
                    !!button.make(Current, tuple.first - 17, tuple.second - 17,
                              bracket.images @ 1, bracket.images @ 2,
                              bracket.images @ 3, planet)
                    button.set_click_handler(agent planet_click(planet))
                    removable_children.add_last(button)
                end
                ip.next
            end
        else
        --Show info for an unexplored system
            name_label.set_text("Star System Unexplored")
            r.set_with_size (58, 95, 240, 130)
            !!msg_label.make (Current, r, starmsgs @ star.kind)
            msg_label.set_justify(false)
            msg_label.set_h_alignment (0.5)
            removable_children.add_last(msg_label)
        end
    end

feature -- Redefined features

    remove is
    do
        star.changed.disconnect (star_changed_handler)
        status.changed.disconnect (status_changed_handler)
        star := Void
        Precursor
    end

    redraw(r: RECTANGLE) is
    local
        tuple: TUPLE[INTEGER, INTEGER]
        i: INTEGER
        ip: ITERATOR[PLANET]
    do
        if dirty then
            dirty := False
    -- Background
            !!cache.make (width, height)
            background.show(cache, 0, 0)
            if star.has_info then
    -- Sun
                suns.item(star.kind - kind_min).show(cache, 157, 120)
    -- Orbits / Asteroid Fields
                from ip := star.get_new_iterator_on_planets until ip.is_off loop
                    if ip.item /= Void then
                        i := ip.item.orbit
                        if ip.item.type = type_asteroids then
                            asteroids.images.item(i).show(cache,
                                29 + asteroids.positions.item(i).x,
                                59 + asteroids.positions.item(i).y)
                        else
                            orbits.item(i).show(cache, 29, 59)
                        end
                    end
                    ip.next
                end
    -- Planets
                from ip.start until ip.is_off loop
                    if ip.item /= Void and then ip.item.colony /= Void then
                        tuple := planet_pos (ip.item)
                        colonies.item (ip.item.colony.owner.color).show(cache, tuple.first - 15, tuple.second - 15)
                    end
                    ip.next
                end
            end
        end
        show_image(cache, 0, 0, r)
        Precursor(r)
    end

    handle_event(event: EVENT) is
    local
        m: EVENT_MOUSE_MOVE
        i: INTEGER
        tick: EVENT_TIMER
        x, y, angle: DOUBLE
        a: BOOLEAN
        ip: ITERATOR[PLANET]
    do
        if handle_ticks then
            tick ?= event
            if tick /= Void then
                tick.set_handled
            end
        end
        Precursor(event)
        if not event.handled then
            m ?= event
            if m /= Void then
                angle := ((m.y - 136.5) * 1.88).atan2(m.x - 173.5)
                from
                    ip := star.get_new_iterator_on_planets
                    a := False
                    i := 0
                until ip.is_off or a loop
                    if ip.item /= Void and then ip.item.type = type_asteroids then
                        y := br * (bi + i + 1)
                        x := y * xm
                        y := cy + angle.sin * y
                        x := cx + angle.cos * x
                        a := (x - m.x).abs < 4 and then (y - m.y).abs < 4
                    end
                    i := i + 1
                    ip.next
                end
                if a /= in_asteroid_field then
                    in_asteroid_field := a
                    if in_asteroid_field then
                        set_planet_text (asteroid_msg)
                    else
                        set_planet_text ("")
                    end
                end
            end
        end
    end

feature -- Controls

    set_planet_text (s: STRING) is
    do
        planet_label.set_text(s)
    end

    set_fleet_click_handler (p: PROCEDURE[ANY, TUPLE[C_FLEET]]) is
    do
        fleets_orbiting.set_fleet_click_handler(p)
    end

    enter_planet (p: PLANET) is
        -- Called when `p' gets under pointer
    local
        text: STRING
    do
        in_asteroid_field := False
        if p.type = type_gasgiant then
            text := "Gas Giant (Uninhabitable)"
        else
            text := star.name + " " + roman @ orbit2planet_number(p.orbit) + "%N" +
                    plsize_names @ p.size + ", " +
                    climate_names @ p.climate + "%N" +
                    mineral_names @ p.mineral + "  " +
                    gravity_names @ p.gravity
            if p.special /= plspecial_nospecial then
                text := text + "%N" + plspecial_names @ p.special
            end
        end
        set_planet_text(text)
    end

    leave_planet (p: PLANET) is
        -- Called when `p' is no longer under pointer
    do
        set_planet_text ("")
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
        -- Assuming STAR.Max_planets = 5
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
        until i > 6 loop
            !!a.make("client/star-view/sun" + i.to_string + ".fma")
            Result.put(a.images @ 1, i)
            i := i + 1
        end
    end

    colonies: ARRAY[IMAGE] is
    local
        i: INTEGER
        a: FMA_FRAMESET
    once
        !!Result.make(0, 7)
        from i := 0
        until i > 7 loop
            !!a.make("client/star-view/colony" + i.to_string + ".fma")
            Result.put(a.images @ 1, i)
            i := i + 1
        end
    end

    bracket: FMA_FRAMESET is
    once
        !!Result.make("client/star-view/bracket.fma")
        Result.images.put(create {SDL_IMAGE}.make(0,0), 1)
    end

    planets: ARRAY2[ANIMATION_FMA] is
    local
        i, j: INTEGER
    once
        !!Result.make(climate_min, climate_max, plsize_min, plsize_max)
        from i := climate_min
        until i > climate_max
        loop
            from j := plsize_min
            until j > plsize_max
            loop
                Result.put(create {ANIMATION_FMA}.make("client/star-view/planet"
                 + (i - climate_min).to_string
                 + (j - plsize_min).to_string
                 + ".fma"), i, j)
                j := j + 1
            end
            i := i + 1
        end
    end

    gas_giant: ANIMATION_FMA is
    once
        !!Result.make("client/star-view/gas-giant.fma")
    end

    asteroids: FMA_FRAMESET is
    local
    once
        !!Result.make("client/star-view/asteroids.fma")
    end

    starmsgs: ARRAY[STRING] is
    local
        file: INPUT_STREAM
        p: PKG_USER
        i: INTEGER
    once
        p.pkg_system.open_file ("client/star-view/starmsgs.txt")
        file := p.pkg_system.last_file_open
        if file = Void then
            print ("Error opening file client/star-view/starmsgs.txt%N")
        else
            !!Result.make(kind_min, kind_max)
            from i := kind_min
            until i > kind_max loop
                file.read_line
                Result.put(file.last_string.twin, i)
                i := i + 1
            end
        end
    end

feature {NONE} -- Internal

    star: C_STAR
    
    status: C_GAME_STATUS

    dirty: BOOLEAN
    cache: SDL_IMAGE

    handle_ticks: BOOLEAN
        -- True when animations are disabled; if so we handle timer_events

    removable_children: ARRAY[WINDOW]
        -- Child windows that will be removed on every on_model_change

    in_asteroid_field: BOOLEAN
        -- True when mouse pointer is inside asteroid field

    asteroid_msg: STRING is "Asteroid Field (Uninhabitable)"

    planet_pos(p: PLANET): TUPLE[INTEGER, INTEGER] is
        -- Calculate `p's position inside view.
    local
        x, y: DOUBLE
    do
        y := br * (bi + p.orbit)
        x := y * xm
        y := cy - (p.orbit + di * status.date).sin * y
        x := cx + (p.orbit + di * status.date).cos * x
        Result := [x.rounded, y.rounded]
    end

    orbit2planet_number(orbit:INTEGER):INTEGER is
    require
        orbit.in_range(1, star.Max_planets)
    local
        i: INTEGER
    do
        from i := 1 until i > orbit loop
            if star.planet_at (i) /= Void then Result := Result + 1 end
            i := i + 1
        end
    end

feature {NONE} -- Internal constants

    -- These numbers are in pixels:
    br: REAL is 12.9  -- base radius, difference between orbits on y axis
    bi: REAL is 0.96  -- base increment, increment for radius to first orbit
    xm: REAL is 1.88  -- x multiplier, x-y ratio for ellipse
    cx: REAL is 173.5 -- center x, x coordinate for center of view
    cy: REAL is 136.5 -- center y, y coordinate for center of view

    di: REAL is .2    -- date increment, amount to increase orbit position
                      -- each turn, in radians

    roman: ARRAY[STRING] is
    once
        Result := << "I", "II", "III", "IV", "V" >>
    end

end -- class STAR_VIEW
