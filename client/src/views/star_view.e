class STAR_VIEW
    -- ews view for a STAR

inherit
    VIEW[C_STAR]
    MAP_CONSTANTS
    WINDOW
        rename make as window_make
        redefine redraw, handle_event end

creation
    make

feature {NONE} -- Creation

    make (w: WINDOW; where: RECTANGLE; new_model: C_STAR) is
        -- build widget as view of `new_model'
    local
        a: FMA_FRAMESET
        r: RECTANGLE
    do
        window_make(w, where)
        set_model(new_model)
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
        in_asteroid_field := false
        on_model_change
    end


feature -- Controls

    set_planet_text (s: STRING) is
    do
        if s.is_equal(asteroid_msg) then
            if not in_asteroid_field then
                planet_label.set_text(s)
                in_asteroid_field := true
            end
        else
            planet_label.set_text(s)
            in_asteroid_field := false
        end
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

feature -- Effective features

    on_model_change is
        -- Update gui
    local
        child: ITERATOR[WINDOW]
        wa: WINDOW_ANIMATED
        msg_label: MULTILINE_LABEL
        button: BUTTON_PLANET
        i: INTEGER
        planet: PLANET
        ani: ANIMATION_FMA
        r: RECTANGLE
        tuple: TUPLE[INTEGER, INTEGER]
    do
        -- Remove removable children
        from child := removable_children.get_new_iterator
        until child.is_off
        loop
            child.item.remove
            child.next
        end
        if model.has_info then
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
        i: INTEGER
    do
        show_image(background, 0, 0, r)
        if model.has_info then
            show_image(suns.item(model.kind - kind_min), 157, 120, r)
            from i := 1
            until i > 5 loop
                if model.planets.item(i) /= Void then
                    if model.planets.item(i).type = type_asteroids then
                        show_image(asteroids.item(i), 29, 59, r)
                    else
                        show_image(orbits.item(i), 29, 59, r)
                    end
                end
                i := i + 1
            end
        end
        Precursor(r)
    end

    handle_event(event: EVENT) is
    local
        b: EVENT_MOUSE_BUTTON
        m: EVENT_MOUSE_MOVE
        i: INTEGER
        x, y, angle: DOUBLE
    do
        Precursor(event)
        if not event.handled then
            b ?= event
            if b /= Void then
                event.set_handled
            else
                m ?= event
                if m /= Void then
                    angle := ((m.y - 136.5) * 1.88).atan2(m.x - 173.5)
                    --print ("[angle:"+ angle.to_string + "r   x:"+ m.x.to_string + " y:" + m.y.to_string)
                    from i := 1
                    until i > 5 loop
                        if model.planets @ i /= Void and then (model.planets @ i).type = type_asteroids then
                            y := br * (bi + i)
                            x := y * xm
                            y := cy + angle.sin * y
                            x := cx + angle.cos * x
                            if (x - m.x).abs < 3 and then (y - m.y).abs < 3 then
                                set_planet_text (asteroid_msg)
                            end
                            --print ("   orbit" + i.to_string + " x:" + x.rounded.to_string + " y:" + y.rounded.to_string)
                        end
                        i := i + 1
                    end
                    --print("%N")
                end
            end
        end
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

    asteroids: ARRAY[IMAGE] is
    local
        i: INTEGER
        a: ANIMATION_FMA
    once
        !!Result.make(1, 5)
        !!a.make("client/star-view/asteroids.fma")
        from i := 1
        until i > 5 loop
            Result.put(a.item, i)
            a.next
            i := i + 1
        end
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

feature {NONE} -- Callbacks

    planet_click is
    do
        print ("Not Yet Implemented%N")
    end

feature {NONE} -- Internal

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
--        y := 24.5 * (.49 + p.orbit * 0.51))
        y := br * (bi + p.orbit)
        x := y * xm
        y := cy - (Pi / 3 * p.orbit).sin * y
        x := cx + (Pi / 3 * p.orbit).cos * x
        Result := [x.rounded, y.rounded]
    end

feature {NONE} -- Internal constants
    -- These numbers are in pixels:
    br: REAL is 12.9  -- base radius, difference between orbits on y axis
    bi: REAL is 0.96  -- base increment, increment for radius to first orbit
    xm: REAL is 1.88  -- x multiplier, x-y ratio for ellipse
    cx: REAL is 173.5 -- center x, x coordinate for center of view
    cy: REAL is 136.5 -- center y, y coordinate for center of view

end -- class STAR_VIEW