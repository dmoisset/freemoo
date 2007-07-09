class TURN_SUMMARY_VIEW
--
-- TODO: Scroll results!

inherit
    WINDOW_MODAL
    rename make as window_make end

create
    make

feature {NONE} -- Creation

    make(w: WINDOW; new_player: C_PLAYER) is
    local
        a: FMA_FRAMESET
        r: RECTANGLE
    do

        player := new_player

        -- Background
        create a.make ("client/turn-summary/bg.fma")
        r.set_with_size((w.width - a.images.item(1).width) // 2,
                        (w.height - a.images.item(1).height) // 2,
                         a.images.item(1).width, a.images.item(1).height)
        window_make(w, r)
        create background.make (Current, 0, 0, a.images @ 1)

        -- Close Button
        create a.make ("client/turn-summary/close.fma")
        create close_button.make (Current, 158, 323,
                        a.images @ 1, a.images @ 1, a.images @ 2)
        close_button.set_click_handler (agent close)

        -- Label
        r.set_with_size(20, 50, width - 60, height - 90)
        create label.make(Current, r, "")

        -- Connect signals
        player.turn_summary_changed.connect(agent update_summary)

        hide
    end

feature {NONE} -- Widgets

    background: WINDOW_IMAGE

    close_button: BUTTON_IMAGE

    label: MULTILINE_LABEL

feature {NONE} -- Internal

    player: C_PLAYER

feature {NONE} -- Callbacks

    close is
    do
        hide
    end

    update_summary is
    local
        msg: STRING
        event: ITERATOR[TURN_SUMMARY_ITEM]
    do
        from
            msg := ""
            event := player.iterator_on_turn_summary
        until
            event.is_off
        loop
            msg := msg + event.item.get_message
            event.next
        end
        label.set_text(msg)
        show
    end

end -- class TURN_SUMMARY_VIEW
