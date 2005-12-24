class MONEY_VIEW

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
    do
        window_make(w, where)
        player := p
        r.set_with_size(0, 0, location.width, row_height)
        create total.make(Current, r, "")
        total.set_font (outlined_font)
        r.set_with_size(0, row_height, location.width, row_height)
        create delta.make(Current, r, "")
        delta.set_font (outlined_font)
        p.money_changed.connect(agent update)
        update
    end

feature -- Operations

    update is
    local
        sign: STRING
    do
        total.set_text(player.money.to_string + " BC")
        if player.money_variation > 0 then
            sign := "+"
        else
            sign := ""
        end
        delta.set_text(sign + player.money_variation.to_string + " BC")
    end

feature {NONE} -- Representation

    player: C_PLAYER

    total, delta: LABEL

    row_height: INTEGER is 14

    outlined_font: FONT is
    once
        create {BITMAP_FONT_FMI}Result.make ("client/gui/outlined-font.fmi")
    end

end -- class MONEY_VIEW
