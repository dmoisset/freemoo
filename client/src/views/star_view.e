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
        r.set_with_size (11, 13, 320, 28)
        !!name_label.make (Current, r, "")
        !!removable_children.make(1, 0)
        on_model_change
    end


feature {NONE} -- Widgets

    close_button: BUTTON

    name_label: LABEL

feature {NONE} -- Callbacks

    close is
    do
        parent.remove_child(Current)
    end

feature -- redefined features

    on_model_change is
        -- Update gui
    local
        i: INTEGER
        ww: WINDOW_IMAGE
        wa: WINDOW_ANIMATED
        child: ITERATOR[WINDOW]
        planet: PLANET
        x, y: DOUBLE
        ani: ANIMATION_FMA
    do
        from child := removable_children.get_new_iterator
        until child.is_off
        loop
            remove_child(child.item)
            child.next
        end
        if model.has_been_visited then
            name_label.set_text("Star System " + model.name)
            !!ww.make(Current, 157, 120, suns.item(model.kind - model.kind_min))
            removable_children.add_last(ww)
            from i := 1
            until i > 5 loop
                planet := model.planets.item(i)
                if planet /= Void then
                    if planet.type = planet.type_asteroids then
                        !!ww.make(Current, 29, 59, asteroids.item(i))
                    else
                        !!ww.make(Current, 29, 59, orbits.item(i))
                        if planet.type = planet.type_gasgiant then
                            ani := gas_giant
                        else
                            ani := planets.item (planet.climate, planet.size)
                        end
                        y := 24.5 * (1 + 0.51 * (planet.orbit - 1))
                        x := y * 1.88
                        y := 136.5 - (Pi / 3 * planet.orbit).sin * y - ani.height / 2
                        x := 173.5 + (Pi / 3 * planet.orbit).cos * x - ani.width / 2
                        !!wa.make(Current, x.rounded, y.rounded, ani)
                        removable_children.add_last(wa)
                    end
                    removable_children.add_last(ww)
                end
                i := i + 1
            end
        else
            name_label.set_text(model.kind_names @ model.kind)
        end
    end

feature -- Redefined features
    redraw(r: RECTANGLE) is
    local
    do
        show_image(background, 0, 0, r)
        Precursor(r)
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

    planets: ARRAY2[ANIMATION_FMA] is
    local
        i, j: INTEGER
    once
        !!Result.make(model.climate_min, model.climate_max, model.plsize_min, model.plsize_max)
        from i := model.climate_min
        until i > model.climate_max
        loop
            from j := model.plsize_min
            until j > model.plsize_max
            loop
                Result.put(create {ANIMATION_FMA}.make("client/star-view/planet"
                 + (i - model.climate_min).to_string
                 + (j - model.plsize_min).to_string
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

feature {NONE} -- Internal

    removable_children: ARRAY[WINDOW]
        -- Child windows that will be removed on every on_model_change

end -- class STAR_VIEW