class COLONY_MORALE_VIEW
    -- Shows the morale frowns/smiles in a row

inherit
    COLONY_VIEW
    redefine handle_event end

create
    make

feature {NONE} -- Creation

    make(w: WINDOW; where: RECTANGLE) is
    do
        my_connect_identifier := agent update_morale
        window_make(w, where)
    end

feature {NONE} -- Signal callbacks

    update_morale is
        -- Update gui
    require
        colony /= Void
    local
        x: INTEGER
        icon: IMAGE
        child: ITERATOR[WINDOW]
        new_child: WINDOW_IMAGE
        morale: INTEGER
    do
        if showing_morale /= colony.morale.total then
            showing_morale := colony.morale.total
            -- Remove masks
            from
                child := children.get_new_iterator
            until
                child.is_off
            loop
                child.item.remove
                child.next
            end
            -- Add masks again
            from
                morale := showing_morale
            variant
                morale.abs
            until
                morale.abs <= 5
            loop
                if morale < 0 then
                    icon := frown
                    morale := morale + 10
                else
                    icon := smile
                    morale := morale - 10
                end
                create new_child.make(Current, x, 0, icon)
                x := x + icon_width
            end
            readjust_positions(children, x)
        end
    end

    handle_event (event: EVENT) is
    local
        b: EVENT_MOUSE_BUTTON
        ac: EXPLAINED_ACCUMULATOR[REAL]
        it: ITERATOR[STRING]
        info: POPUP_INFO
        msg: STRING
    do
        Precursor (event)
        if not event.handled then
            b ?= event
            if b /= Void and then not b.state then
                event.set_handled
                if b.button = 1 and then colony /= Void then
                    ac := colony.morale
                    from
                        msg := ""
                        it := ac.get_new_iterator_on_reasons
                    until
                        it.is_off
                    loop
                        if ac @ it.item > 0 then
                            msg := msg + "+"
                        end
                        msg := msg + ((ac @ it.item).to_string_format(1)
                                   + " " + it.item + "%N")
                        it.next
                    end
                    msg := msg + "------------------%N"
                               + ac.total.to_string_format(1) + " Total"
                    create info.make(parent, msg)
                end
            end
        end
    end

feature {NONE} -- Cacheing

    showing_morale: INTEGER

feature {NONE} -- Implementation constants

    icon_width: INTEGER is 30

feature {NONE} -- Images

    smile: IMAGE is
    local
        a: FMA_FRAMESET
    once
        create a.make("client/colony-view/morale/smile.fma")
        Result := a.images @ 1
    end

    frown: IMAGE is
    local
        a: FMA_FRAMESET
    once
        create a.make("client/colony-view/morale/frown.fma")
        Result := a.images @ 1
    end

end -- class COLONY_MORALE_VIEW
