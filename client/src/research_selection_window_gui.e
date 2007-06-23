deferred class RESEARCH_SELECTION_WINDOW_GUI

inherit
    WINDOW
    redefine make, handle_event end
    GETTEXT
    TECHNOLOGY_CONSTANTS
    KEYBOARD_CONSTANTS

feature {NONE} -- Creation

    make (w: WINDOW; where: RECTANGLE) is
        -- Build GUI
    local
        a: FMA_FRAMESET
        r: RECTANGLE
        button: BUTTON_IMAGE
        i: INTEGER
    do
        Precursor (w, where)
        create a.make ("client/research-selection/background.fma")
        left := (width - a.images.item(1).width) // 2
        create background.make (Current, left, 0, a.images @ 1)
        create category_buttons.make (category_construction, category_force_fields)
        from
            i := category_construction
        until
            i > category_force_fields
        loop
            create a.make ("client/research-selection/category" + i.to_string + ".fma")
            create button.make (Current, left + 21 + (227 * (i \\ 2)),
                                30 + (i // 2) * 105 + 2 * (i // 6),
                                a.images @ 1,
                                a.images @ 1, a.images @ 2)
            i := i + 1
        end
    end

feature {NONE} -- Widgets

    background: WINDOW_IMAGE
    category_buttons: ARRAY [BUTTON_IMAGE]

    new_name (where: RECTANGLE) is deferred end
    new_population (where: RECTANGLE) is deferred end
    new_populators (where: RECTANGLE) is deferred end
    new_morale (where: RECTANGLE) is deferred end
    new_production (where: RECTANGLE) is deferred end
    new_producing (where: RECTANGLE) is deferred end
    new_system_view (where: RECTANGLE) is deferred end
    new_possible_constructions (where: RECTANGLE) is deferred end

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
