class COLONY_POPULATION_VIEW
    -- ews view for current stardate

inherit
    WINDOW
    rename make as window_make end

creation
    make

feature -- Representation

   colony: C_COLONY

feature {NONE} -- Creation

    make (w:WINDOW; where: RECTANGLE) is
        -- build widget without a model
    local
        r: RECTANGLE
    do
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
    local
        s: STRING
        growth: INTEGER
    do
        s := "Population: " + colony.population.to_string + "000 ("
        growth := colony.population_growth
        if growth >= 0 then
          s := s + "+"
        end
        s := s + growth.to_string + "k)"
        label.set_text (s)
    end

    set_colony(c: C_COLONY) is
    do
        if colony /= Void then
            colony.changed.disconnect(agent update_population)
        end
        colony := c
        colony.changed.connect(agent update_population)
        update_population
    end

feature {NONE} -- Widgets

    label: LABEL

end -- class COLONY_POPULATION_VIEW