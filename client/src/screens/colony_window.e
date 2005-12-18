class COLONY_WINDOW

inherit
    COLONY_WINDOW_GUI

creation
    make

feature

    set_colony(c: C_COLONY) is
    require
        c /= Void
    do
        c.recalculate_production
        name.set_colony(c)
        system_view.set_colony(c)
        population.set_colony(c)
        populators.set_colony(c)
        production.set_colony(c)
        possible_constructions.set_colony(c)
    end

feature {NONE} -- Widgets

    new_name(where: RECTANGLE) is
    do
        !!name.make(Current, where)
    end

    new_population(where: RECTANGLE) is
    do
        !!population.make(Current, where)
    end

    new_populators(where: RECTANGLE) is
    do
        !!populators.make(Current, where)
    end

    new_production(where: RECTANGLE) is
    do
        !!production.make(Current, where)
    end

    new_possible_constructions(where: RECTANGLE) is
    do
        !!possible_constructions.make(Current, where)
    end

    new_system_view(where: RECTANGLE) is
    do
        !!system_view.make(Current, where)
        system_view.set_manage_colony_callback(agent set_colony)
    end

end -- class COLONY_WINDOW
