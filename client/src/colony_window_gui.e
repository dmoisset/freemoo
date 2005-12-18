deferred class COLONY_WINDOW_GUI

inherit
    WINDOW
    redefine make end
    GETTEXT

feature {NONE} -- Creation

    make (w: WINDOW; where: RECTANGLE) is
        -- Build GUI
    local
        a, a2: FMA_FRAMESET
        r: RECTANGLE
    do
        Precursor (w, where)
        !!a.make ("client/colony-window/colony-background.fma")
        !!background.make (Current, 0, 0, a.images @ 1)

        r.set_with_size(193, 15, 255, 19)
        new_name(r)

        r.set_with_size(490, 14, 155, 19)
        new_population(r)

        r.set_with_size(18, 47, 120, 130)
        new_system_view(r)

        r.set_with_size(328, 78, 200, 100)
        new_populators(r)

        r.set_with_size(138, 47, 168, 140)
        new_production(r)

        !!a.make ("client/colony-window/close1.fma")
        !!a2.make ("client/colony-window/close2.fma")
        !BUTTON_IMAGE!close_button.make(background, 556, 449,
             create {SDL_SOLID_IMAGE}.make(0, 0, 80,80,250),
             a.images @ 1, a2.images @ 1)
        close_button.set_click_handler(agent close)
    end

feature {NONE} -- Widgets

    background: WINDOW_IMAGE
    close_button: BUTTON
    name: COLONY_NAME_VIEW
    system_view: COLONY_STAR_VIEW
    population: COLONY_POPULATION_VIEW
    populators: COLONY_POPULATORS_VIEW
    production: COLONY_PRODUCTION_VIEW
    new_name (where: RECTANGLE) is deferred end
    new_population (where: RECTANGLE) is deferred end
    new_populators (where: RECTANGLE) is deferred end
    new_production (where: RECTANGLE) is deferred end
    new_system_view (where: RECTANGLE) is deferred end

feature {NONE} -- Callbacks

    close is
    local
        connection_window: CONNECTION_WINDOW
    do
        connection_window ?= parent
        hide
        connection_window.goto_main_window
    end

end -- class COLONY_WINDOW_GUI
