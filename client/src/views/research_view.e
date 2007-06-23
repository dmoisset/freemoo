class RESEARCH_VIEW

inherit
    WINDOW
    rename
        make as window_make
    end

creation
    make

feature {NONE} -- Creation

    make(w: WINDOW; where: RECTANGLE; p: C_PLAYER) is
    local
        r: RECTANGLE
        y_pos: INTEGER
    do
        window_make(w, where)
        player := p
        y_pos := (height - 2 * row_height) // 2
        r.set_with_size(0, y_pos, location.width, row_height)
        create turns.make(Current, r, "")
        turns.set_font (outlined_font)

        y_pos := y_pos + row_height
        r.set_with_size(0, y_pos, location.width, row_height)
        create delta.make(Current, r, "")
        delta.set_font (outlined_font)
        p.colonies_changed.connect(agent update)
        r.set_with_size(0, 0, width, height)
        create show_dialog_button.make (Current, r)
        show_dialog_button.set_click_handler (agent show_selection_dialog)
        update
    end

feature -- Operations

    update is
    local
        missing: INTEGER
    do
        if player.research_variation > 0 then
            missing := (250 - player.research) // player.research_variation
                -- Imagine we're researching a 250RP item just for now
            turns.set_text("~" + missing.to_string + " turns")
        else
            turns.set_text("Never")
        end
        delta.set_text(player.research_variation.to_string + " RP")
    end

feature -- Callbacks

    show_selection_dialog is
    local
        connect_window: CONNECTION_WINDOW
    do
        connect_window ?= parent.parent
        connect_window.goto_research_window
    end

feature {NONE} -- Representation

    player: C_PLAYER

    turns, delta: LABEL

    show_dialog_button: BUTTON

    row_height: INTEGER is 14

    outlined_font: FONT is
    once
        create {BITMAP_FONT_FMI}Result.make ("client/gui/outlined-font.fmi")
    end

end -- class RESEARCH_VIEW
