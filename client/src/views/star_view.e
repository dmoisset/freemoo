class STAR_VIEW
    -- ews view for a STAR

inherit
    VIEW[C_STAR]
    VIEW[C_GAME_STATUS]
    MAP_CONSTANTS
    WINDOW
        rename make as window_make
        redefine redraw, handle_event end

creation
    make

feature {NONE} -- Creation

    make (w: WINDOW; where: RECTANGLE; new_model: C_STAR; new_status: C_GAME_STATUS) is
        -- build widget as view of `new_model'
    require
        w /= Void
        new_model /= Void
        new_status /= Void
    local
        a: FMA_FRAMESET
        r: RECTANGLE
        d: DRAG_HANDLE
    do
        window_make(w, where)
        -- Register Primary model
        set_model(new_model)
        -- Register Secondary model
        status := new_status
        new_status.add_view(Current)
        -- Drag Handle
        r.set_with_size(0, 0, 347, 45)
        !!d.make(Current, r)
--        d.set_pre_drag (agent disable_animations)
  --      d.set_post_drag (agent enable_animations)
        -- Close Button
        !!a.make ("client/star-view/close-button.fma")
        !BUTTON_IMAGE!close_button.make (Current, 262, 235,
            a.images @ 1, a.images @ 1, a.images @ 2)
        close_button.set_click_handler (agent close)
        -- Name label
        r.set_with_size (11, 13, 320, 28)
        !!name_label.make (Current, r, "")
        -- Planet label
        r.set_with_size (15, 50, 310, 100)
        !!planet_label.make (Current, r, "")
        !!removable_children.make(1, 0)
        -- Fleet hotspots
        !!fleet_hotspots.make
        on_model_change
    end

feature {NONE} -- Widgets

    close_button: BUTTON

    name_label: LABEL

    planet_label: MULTILINE_LABEL


feature {NONE} -- Callbacks

    close is
    do
        remove
    end

    enable_animations is
    do
        handle_ticks := False
    end

    disable_animations is
    do
        handle_ticks := True
    end

feature {NONE} -- Callbacks

    planet_click is
    do
        print ("Not Yet Implemented%N")
    end

    fleet_click_handler: PROCEDURE[ANY, TUPLE[C_FLEET]]

feature -- Effective features

    on_model_change is
        -- Update gui
    local
        child: ITERATOR[WINDOW]
        fleet: ITERATOR[C_FLEET]
        wa: WINDOW_ANIMATED
        msg_label: MULTILINE_LABEL
        button: BUTTON_PLANET
        i: INTEGER
        planet: PLANET
        ani: ANIMATION_FMA
        r: RECTANGLE
        tuple: TUPLE[INTEGER, INTEGER]
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
        -- Generate hotspots
        fleet_hotspots.clear
        from
            fleet := model.fleets.get_new_iterator_on_items
            i := 0
        until fleet.is_off
        loop
            r.set_with_size(fleet_pic_firstx + i * (fleet_pic_width + fleet_pic_margin), fleet_pic_y, fleet_pic_width, fleet_pic_height)
            fleet_hotspots.add (r, fleet.item.id)
            fleet.next
            i := i + 1
        end
        if model.has_info then
        -- Show info for an known system
            name_label.set_text("Star System " + model.name)
            from i := 1
            until i > 5 loop
                planet := model.planets.item(i)
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
                    button.set_click_handler(agent planet_click)
                    removable_children.add_last(button)
                end
                i := i + 1
            end
        else
        --Show info for an unexplored system
            name_label.set_text("Star System Unexplored")
            r.set_with_size (58, 95, 240, 130)
            !!msg_label.make (Current, r, starmsgs @ model.kind)
            msg_label.set_justify(false)
            msg_label.set_h_alignment (0.5)
            removable_children.add_last(msg_label)
        end
    end

feature -- Redefined features

    redraw(r: RECTANGLE) is
    local
        tuple: TUPLE[INTEGER, INTEGER]
        i: INTEGER
        fleet_it: ITERATOR[C_FLEET]
    do
        if dirty then
            dirty := False
    -- Background
            !!cache.make (width, height)
            background.blit(cache, 0, 0)
            if model.has_info then
    -- Sun
                suns.item(model.kind - kind_min).blit(cache, 157, 120)
    -- Orbits / Asteroid Fields
                from i := 1
                until i > 5 loop
                    if model.planets.item(i) /= Void then
                        if model.planets.item(i).type = type_asteroids then
									asteroids.images.item(i).blit(cache,
											 29 + asteroids.positions.item(i).x,
											 59 + asteroids.positions.item(i).y)
                        else
                            orbits.item(i).blit(cache, 29, 59)
                        end
                    end
                    i := i + 1
                end
    -- Planets
                from i := 1
                until i > 5 loop
                    if model.planets.item(i) /= Void and then model.planets.item(i).colony /= Void then
                        tuple := planet_pos(model.planets.item(i))
                        colonies.item(model.planets.item(i).colony.owner.color).blit(cache, tuple.first - 15, tuple.second - 15)
                    end
                    i := i + 1
                end
            end
    -- Fleets
            from
                fleet_it := model.fleets.get_new_iterator_on_items
                i := fleet_pic_firstx
            until fleet_it.is_off
            loop
                fleets.item(fleet_it.item.owner.color).blit(cache, i, fleet_pic_y)
                i := i + (fleets @ fleet_it.item.owner.color).width + fleet_pic_margin
                fleet_it.next
            end
        end
        show_image(cache, 0, 0, r)
        Precursor(r)
    end

    handle_event(event: EVENT) is
    local
        b: EVENT_MOUSE_BUTTON
        m: EVENT_MOUSE_MOVE
        tick: EVENT_TIMER
        i: INTEGER
        x, y, angle: DOUBLE
        a: BOOLEAN
        it: ITERATOR[RECTANGLE]
    do
        if handle_ticks then
            tick ?= event
            if tick /= Void then
                tick.set_handled
            end
        end
        Precursor(event)
        if not event.handled then
            b ?= event
            if b /= Void then
                event.set_handled
                if b.button = 1 and not b.state then
                    from it := fleet_hotspots.get_new_iterator_on_items
                    until it.is_off
                    loop
                        if (it.item.has(b.x, b.y)) then
                            if fleet_click_handler /= Void then
                                fleet_click_handler.call([model.fleets @ (fleet_hotspots.key_at(it.item))])
                            end
                        end
                        it.next
                    end
                end
            else
                m ?= event
                if m /= Void then
                    angle := ((m.y - 136.5) * 1.88).atan2(m.x - 173.5)
                    from
                        i := 1
                        a := False
                    until i > 5 or a loop
                        if model.planets @ i /= Void and then (model.planets @ i).type = type_asteroids then
                            y := br * (bi + i)
                            x := y * xm
                            y := cy + angle.sin * y
                            x := cx + angle.cos * x
                            a := (x - m.x).abs < 4 and then (y - m.y).abs < 4
                        end
                        i := i + 1
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
    end

feature -- Controls

    set_planet_text (s: STRING) is
    do
        planet_label.set_text(s)
    end

    set_fleet_click_handler (p: PROCEDURE[ANY, TUPLE[C_FLEET]]) is
    do
        fleet_click_handler := p
    end

    enter_planet (p: PLANET) is
        -- Called when `p' gets under pointer
    do
        in_asteroid_field := False
        if p.type = type_gasgiant then
            set_planet_text ("Gas Giant (Uninhabitable)")
        else
            set_planet_text (model.name + " " + roman @ orbit2planet_number(p.orbit) + "%N" +
                             plsize_names @ p.size + ", " +
                             climate_names @ p.climate + "%N" +
                             mineral_names @ p.mineral + "  " +
                             gravity_names @ p.gravity)
        end
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

    fleets: ARRAY[IMAGE] is
    local
        i: INTEGER
        a: FMA_FRAMESET
    once
        !!Result.make(0, 7)
        from i := 0
        until i > 7 loop
            !!a.make("client/star-view/fleet" + i.to_string + ".fma")
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

    status: C_GAME_STATUS

    dirty: BOOLEAN
    cache: SDL_IMAGE

    handle_ticks: BOOLEAN
        -- True when animations are disabled; if so we handle timer_events

    removable_children: ARRAY[WINDOW]
        -- Child windows that will be removed on every on_model_change

    fleet_hotspots: DICTIONARY[RECTANGLE, INTEGER]

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
        orbit.in_range(1, 5)
    local
        i: INTEGER
    do
        from i := 1 until i > orbit loop
            if model.planets @ i /= Void then Result := Result + 1 end
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

    fleet_pic_firstx: INTEGER is 20
    fleet_pic_margin: INTEGER is 5
    fleet_pic_y: INTEGER is 239
    fleet_pic_width: INTEGER is 17
    fleet_pic_height: INTEGER is 14

    roman: ARRAY[STRING] is
    once
        Result := << "I", "II", "III", "IV", "V" >>
    end

end -- class STAR_VIEW
