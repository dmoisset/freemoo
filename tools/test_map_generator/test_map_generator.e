class TEST_MAP_GENERATOR

inherit
    JEGL
    J_SCREEN_ACCESS
    J_CONSTANTS
    MAP_CONSTANTS

creation {ANY}
    make

feature {ANY}

    init is
    local
        color: J_COLOR
    do
        set_videomode (640, 480, 16, false)
        !!events
        !!keyboard
        keyboard.enable_repeat(500,100)
        !!font.make ("small_font.png")
        !!area.make (430, 0, 210, 480)
        !!colors.make
        !!color.make (100, 100, 100)
        colors.add (color, kind_blackhole)
        !!color.make (0, 193, 244)
        colors.add (color, kind_bluewhite)
        !!color.make (234, 109, 0)
        colors.add (color, kind_orange)
        !!color.make (234, 0, 0)
        colors.add (color, kind_red)
        !!color.make (255, 255, 255)
        colors.add (color, kind_white)
        !!color.make (234, 222, 0)
        colors.add (color, kind_yellow)
        !!color.make (104, 69, 0)
        colors.add (color, kind_brown)
        !!color.make (0, 0, 0)
        colors.add (color, 100)
    end -- init

    make is
    local
        done: BOOLEAN
        mapgen: MAP_GENERATOR_V1
        i: INTEGER
        proj: PROJECTION
        selected: INTEGER
        options: OPTION_LIST
        plist: PLAYER_LIST[PLAYER]
    do
        init
        !!options.make
        options.parse_add ("galaxysize = huge")
        options.parse_add ("galaxyage = average")
        !!mapgen.make (options)
        !!proj
        !!plist.make
        !!galaxy.make
        mapgen.generate (galaxy, plist)
        screen.lock
        from
            i := galaxy.stars.lower
        until
            i > galaxy.stars.upper
        loop
            proj.project (galaxy.stars.item (i))
            screen.put_pixel (proj.x.rounded, proj.y.rounded, colors.at(galaxy.stars.item (i).kind))
            i := i + 1
        end
        screen.unlock
        selected := galaxy.stars.lower
        show(selected)
        from
            done := false
        until
            done = true
        loop
            if events.poll then
                inspect
                    events.type
                when je_keydown then
                    if keyboard.sym = jk_escape then
                        done := true
                    elseif keyboard.sym = jk_down then
                        erase (selected)
                        selected := selected + 1
                        if selected > galaxy.stars.upper then
                            selected := galaxy.stars.lower
                        end
                        show (selected)
                    elseif keyboard.sym = jk_up then
                        erase (selected)
                        selected := selected - 1
                        if selected < galaxy.stars.lower then
                            selected := galaxy.stars.upper
                        end
                        show (selected)
                    end
                when je_quit then
                    done := true
                else
                end
            end
        end
        jegl_quit
    end -- make

    show (i:INTEGER) is
    local
        proj: expanded PROJECTION
        j: INTEGER
        planet: PLANET
    do
        screen.lock
        proj.project (galaxy.stars.item (i))
        if proj.x > 2 and proj.y > 2 then
            screen.put_pixel (proj.x.rounded - 2, proj.y.rounded - 2, colors @ kind_white)
        end
        if proj.y > 2 then
            screen.put_pixel (proj.x.rounded + 2, proj.y.rounded - 2, colors @ kind_white)
        end
        if proj.x > 2 then
            screen.put_pixel (proj.x.rounded - 2, proj.y.rounded + 2, colors @ kind_white)
        end
        screen.put_pixel (proj.x.rounded + 2, proj.y.rounded + 2, colors @ kind_white)
        screen.unlock
        if galaxy.stars.item (i).kind /= kind_blackhole then
            font.put_string (screen, 450, 20, galaxy.stars.item (i).name)
            font.put_string (screen, 510, 35, stsize_names.at (galaxy.stars.item (i).size))
            from
                j := 1
            until
                j > 5
            loop
                planet := galaxy.stars.item (i).planets.item (j)
                if planet /= Void then
                    if planet.type = type_planet then
                        font.put_string (screen, 450, 80 * j, plsize_names.at (planet.size))
                        font.put_string (screen, 450, 80 * j + 15, climate_names.at (planet.climate))
                        font.put_string (screen, 450, 80 * j + 30, mineral_names.at (planet.mineral))
                        font.put_string (screen, 510, 80 * j + 30, gravity_names.at (planet.gravity))
                    else
                        font.put_string (screen, 450, 80 * j, type_names.at (planet.type))
                    end
                end
                j := j + 1
            end
        end
        font.put_string (screen, 450, 35, kind_names.at (galaxy.stars.item (i).kind))
        screen.flip
    end

    erase (i:INTEGER) is
    local
        proj: expanded PROJECTION
    do
        screen.lock
        proj.project (galaxy.stars.item (i))
        if proj.x > 2 and proj.y >2 then
            screen.put_pixel(proj.x.rounded - 2, proj.y.rounded - 2, colors @ 100)
        end
        if proj.y > 2 then
            screen.put_pixel(proj.x.rounded + 2, proj.y.rounded - 2, colors @ 100)
        end
        if proj.x > 2 then
            screen.put_pixel(proj.x.rounded - 2, proj.y.rounded + 2, colors @ 100)
        end
        screen.put_pixel(proj.x.rounded + 2, proj.y.rounded + 2, colors @ 100)
        screen.unlock
        screen.fill_area(area, colors @ 100)
    end

feature {NONE}

    events: J_EVENTS

    keyboard: J_KEYBOARD

    colors: DICTIONARY[J_COLOR, INTEGER]

    galaxy: GALAXY

    font: J_FONT

    area: J_AREA
end -- class TEST_MAP_GENERATOR
