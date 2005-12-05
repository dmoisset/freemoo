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
        name.set_colony(c)
        population.set_colony(c)
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

end -- class COLONY_WINDOW
