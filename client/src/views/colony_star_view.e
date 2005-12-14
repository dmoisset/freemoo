class COLONY_STAR_VIEW
    -- Shows a colony's neighbouring planets

inherit
    COLONY_VIEW
    CLIENT
    MAP_CONSTANTS

creation
    make

feature -- Operations

    set_manage_colony_callback(p: PROCEDURE[ANY, TUPLE[C_COLONY]]) is
    do
        manage_colony_callback := p
    end

feature {NONE} -- Signal callbacks

    update_star is
        -- Update gui
    require
        colony /= Void
    local
        child: ITERATOR[WINDOW]
        msg: STRING
        orbit: INTEGER
        icon: IMAGE
        button: BUTTON_IMAGE
        image: WINDOW_IMAGE
        ani: WINDOW_ANIMATED
        planet: C_PLANET
        star: C_STAR
    do
        star := colony.location.orbit_center
        -- Remove planets
        from
            child := planets.get_new_iterator
        until
            child.is_off
        loop
            child.item.remove
            child.next
        end
        planets.clear
        -- Add planets again
        from
            orbit := 1
        until
            orbit > star.Max_planets
        loop
            if star.planet_at(orbit) /= Void and then
               star.planet_at(orbit).colony /= Void and then
               star.planet_at(orbit).colony.id = colony.id then
                create ani.make (Current, 0, row_height * (orbit - 1), cursor_glowing)
                planets.add_last(ani)
            else
                create image.make(Current, 0, row_height * (orbit - 1), cursor_grayed)
                planets.add_last(image)
            end
            if star.planet_at(orbit) = Void then
                labels.item(orbit).set_text("")
            else
                planet := star.planet_at(orbit)
                if planet.type = type_planet then
                    icon := planet_icons.item(planet.climate, planet.size)
                    if planet.colony /= Void and then
                        planet.colony.id /= colony.id and then
                        planet.colony.owner.id = colony.owner.id then
                        -- We can control this colony
                        create button.make(Current, planet_x, row_height * (orbit - 1),
                                        icon, icon, icon)
                        button.set_click_handler(agent manage_colony(planet.colony))
                        planets.add_last(button)
                    else
                        create image.make(Current, planet_x, row_height * (orbit - 1), icon)
                        planets.add_last(image)
                    end
                    if planet.colony /= Void then
                        msg := planet.colony.owner.race.name + " (" +
                               planet.colony.populators.count.to_string +
                               "/" + planet.colony.max_population.to_string + ")"
                    else
                        msg := (plsize_names @ planet.size) + " " +
                               (climate_names @ planet.climate)
                    end
                    labels.item(orbit).set_text(msg)
                else
                    create image.make(Current, planet_x, row_height * (orbit - 1),
                                      other_icons @ planet.type)
                    labels.item(orbit).set_text(type_names @ planet.type)
                    planets.add_last(image)
                end
            end
            orbit := orbit + 1
        end
    end

feature {NONE} -- Callbacks

    manage_colony(c: C_COLONY) is
    do
        print ("Manage colony at orbit " + c.location.orbit.to_string + "%N")
        if manage_colony_callback /= Void then
            manage_colony_callback.call([c])
        end
    end

    manage_colony_callback: PROCEDURE[ANY, TUPLE[C_COLONY]]

feature {NONE} -- Implementation

    planets: ARRAY[WINDOW]

    labels: ARRAY[MULTILINE_LABEL]

    font: BITMAP_FONT_FMI

    planet_x: INTEGER is 10

    label_x: INTEGER is 35

    row_height: INTEGER is 26

feature {NONE} -- Images

    planet_icons: ARRAY2[IMAGE] is
    local
        a: FMA_FRAMESET
        i, j: INTEGER
    once
        create Result.make(climate_min, climate_max, plsize_min, plsize_max)
        from i := climate_min until i > climate_max loop
            from j := plsize_min until j > plsize_max loop
                !!a.make("client/colony-view/planets/planet" +
                         (i - climate_min).to_string +
                         (j - plsize_min).to_string + ".fma")
                Result.put(a.images @ 1, i, j)
                j := j + 1
            end
            i := i + 1
        end
    end

    other_icons: ARRAY[IMAGE] is
    local
        a: FMA_FRAMESET
    once
        create Result.make(type_min, type_max)
        create a.make("client/colony-view/planets/gas_giant.fma")
        Result.put(a.images @ 1, type_gasgiant)
        create a.make("client/colony-view/planets/asteroids.fma")
        Result.put(a.images @ 1, type_asteroids)
    end

    cursor_glowing: ANIMATION_FMA_TRANSPARENT is
        -- Active (glowing) cursor
    once
        create Result.make("client/colony-view/planets/cursor_active.fma")
        Result.set_full_loop
    end

    cursor_grayed: IMAGE is
    local
        a: FMA_FRAMESET
    once
        create a.make("client/colony-view/planets/cursor_grayed.fma")
        Result := a.images @ 1
    end


feature {NONE} -- Creation

    make(w: WINDOW; where: RECTANGLE) is
    local
        i: INTEGER
        r: RECTANGLE
    do
        my_connect_identifier := agent update_star
        window_make(w, where)
        create planets.make(1,0)
        create labels.make(1, 5) -- Max_planets should be in MAP_CONSTANTS
        create font.make("client/gui/medium_colony_font.fmi")
        from
            i := 1
        until
            i > 5
        loop
            r.set_with_size(label_x, row_height * (i - 1), 50, row_height)
            labels.put(create {MULTILINE_LABEL}.make(Current, r, ""), i)
            labels.item(i).set_font(font)
            i := i + 1
        end
    end


end -- class COLONY_STAR_VIEW
