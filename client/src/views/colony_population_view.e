class COLONY_POPULATION_VIEW
    -- Shows a colony's total population and it's growth for next turn

inherit
    COLONY_VIEW

creation
    make

feature {NONE} -- Creation

    make (w:WINDOW; where: RECTANGLE) is
        -- build widget without a model
    local
        r: RECTANGLE
    do
        my_connect_identifier := agent update_population
        window_make(w, where)
        r.set_with_size(0, 0, location.width, location.height)
        !!label.make (Current, r, "")
        label.set_h_alignment(label.horz_align_left)
        label.set_v_alignment(label.vert_align_center)
    end

feature -- Redefined features

    update_population is
        -- Update gui
    require
        colony /= Void
        colony.populators.count > 0
    local
        s: STRING
        growth: INTEGER
    do
        s := "Population: " + colony.population.to_string + "k ("
        growth := colony.population_growth
        if growth >= 0 then
          s := s + "+"
        end
        s := s + growth.to_string + "k)"
        label.set_text (s)
    end

feature {NONE} -- Widgets

    label: LABEL

end -- class COLONY_POPULATION_VIEW
