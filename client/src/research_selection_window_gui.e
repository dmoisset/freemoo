deferred class RESEARCH_SELECTION_WINDOW_GUI

inherit
    WINDOW
    redefine make, handle_event end
    TECHNOLOGY_CONSTANTS
    KEYBOARD_CONSTANTS

feature {NONE} -- Creation

    make (w: WINDOW; where: RECTANGLE) is
        -- Build GUI
    local
        a: FMA_FRAMESET
        r: RECTANGLE
        button: BUTTON_IMAGE_GROUPABLE
        i, j: INTEGER
        normal, prelight, pressed, highlight: IMAGE_FMI
        label: LABEL
    do
        Precursor (w, where)
        create a.make ("client/research-selection/background.fma")
        left := (width - a.images.item(1).width) // 2
        create background.make (Current, left, 0, a.images @ 1)
        create category_buttons.make (category_construction, category_force_fields)
        create normal.make_from_file ("client/research-selection-window/button_normal.fmi")
        create prelight.make_from_file ("client/research-selection-window/button_prelight.fmi")
        create pressed.make_from_file ("client/research-selection-window/button_pressed.fmi")
        create highlight.make_from_file ("client/research-selection-window/selected_highlight.fmi")
        create tech_buttons.make (category_construction, category_force_fields)
        create tech_labels.make (category_construction, category_force_fields)
        create tech_groups.make (category_construction, category_force_fields)
        create selected_highlight.make (1, 4)
        from
            i := 1
        until
            i > 4
        loop
            selected_highlight.put (create {WINDOW_IMAGE}.make (Current, 0, 0, highlight), i)
            i := i + 1
        end
        from
            i := category_construction
        until
            i > category_force_fields
        loop
            tech_buttons.put (create{ARRAY[BUTTON_IMAGE_GROUPABLE]}.make (1, 4), i)
            tech_labels.put (create{ARRAY[LABEL]}.make (1, 4), i)
            tech_groups.put (create{BUTTON_GROUP}.make, i)
            create a.make ("client/research-selection/category" + i.to_string + ".fma")
            create button.make (Current, left + 21 + (227 * (i \\ 2)),
                                30 + (i // 2) * 105 + 2 * (i // 6),
                                a.images @ 1, a.images @ 1, a.images @ 2)
            from
                j := 1
            until
                j > 4
            loop
                r.set_with_size (left + 15 + (227 * (i \\ 2)),
                                 30 + (i // 2) * 105 + 2 * (i // 6) + 20 * j,
                                 216, 17)
                create label.make (Current, r, "")
                tech_labels.item (i).put (label, j)
                create button.make (Current, left + 15 + (227 * (i \\ 2)),
                                    30 + (i // 2) * 105 + 2 * (i // 6) + 20 * j,
                                    normal, prelight, pressed)
                tech_buttons.item (i).put (button, j)
                j := j + 1
            end
            i := i + 1
        end
    end

feature {NONE} -- Widgets

    background: WINDOW_IMAGE
    category_buttons: ARRAY [BUTTON_IMAGE]

    tech_buttons: ARRAY [ARRAY [BUTTON_IMAGE_GROUPABLE]]
    tech_labels: ARRAY [ARRAY [LABEL]]
    tech_groups: ARRAY [BUTTON_GROUP]

    selected_highlight: ARRAY [WINDOW_IMAGE]

feature {NONE} -- Callbacks

    close is
    local
        connection_window: CONNECTION_WINDOW
    do
        connection_window ?= parent
        hide
        connection_window.goto_main_window
    end

feature -- Event handling

    handle_event (ev: EVENT) is
    local
        k: EVENT_KEY
    do
        k ?= ev
        if k /= Void and then (k.state and k.symbol = key_escape) then
            close
        end
        Precursor (ev)
    end

feature {NONE} -- Auxiliar

    left: INTEGER -- The leftmost coordinate of our visible window

end -- class RESEARCH_SELECTION_WINDOW_GUI
