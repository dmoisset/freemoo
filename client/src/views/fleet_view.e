--TODO:
--auto shrink with small fleets
--color the scrollbar trough
--implement scrollbar
--implement selection
--implement the "all" button
--show destination or orbit center in the title
--handle special cases (monsters, guardian)


class FLEET_VIEW
    --ews class view for a FLEET

inherit
    VIEW[C_FLEET]
    WINDOW
        rename make as window_make
        redefine redraw, handle_event end

creation
    make

feature {NONE} -- Creation

    make (w: WINDOW; where: RECTANGLE; new_model: C_FLEET) is
        -- build widget as view of `new_model'
    local
        wi: WINDOW_IMAGE
        b: BUTTON_IMAGE
        r: RECTANGLE
        d: DRAG_HANDLE
        vpos: INTEGER
    do

        window_make(w, where)
        set_model (new_model)

        r.set_with_size (1, 0, (window_top @ 1).width, (window_top @ 1).height)
        !!d.make (Current, r)

        !!wi.make (Current, 1, vpos, window_top @ 1)
        vpos := vpos + (window_top @ 1).height

        !!wi.make (Current, 2, vpos, window_middle @ 1)
        !!wi.make (Current, 190, vpos+32, scrollbar @ 3)
        vpos := vpos + (window_middle @ 1).height

        !!wi.make (Current, 0, vpos, window_bottom @ 1)
        !!b.make (Current, 16, vpos+4, all_button @ 1, all_button @ 1, all_button @ 2)
        b.set_click_handler (agent select_all)
        vpos := vpos + (window_bottom @ 1).height

        !!b.make (Current, 2, vpos, close_button @ 1, close_button @ 1, close_button @ 2)
        b.set_click_handler (agent close)

    end

feature {NONE} -- Callbacks

    close is
    do
        remove
    end

    select_all is
    do
    end

feature {NONE} -- Implementation

--FIXME: FLEET must have an array of ships for this to work, not a set
    ship_pos: INTEGER   -- index of the first ship displayed in this window

feature -- Redefined features

    redraw (r: RECTANGLE) is
    do
        Precursor (r)
    end

    handle_event (event: EVENT) is
    do
        Precursor (event)
        if not event.handled then
        end
    end


feature {MODEL}

    on_model_change is
        --Update gui
    do
    end

feature {NONE} -- Once features

    --For each window_* array, the first image has scrollbar, the second doesn't

    window_top: ARRAY[IMAGE] is
    local
        a: FMA_FRAMESET
    once
        !!Result.make(1, 2)
        !!a.make("client/fleet-view/window-top-s.fma")
        Result.put (a.images @ 1, 1)
        !!a.make("client/fleet-view/window-top-ns.fma")
        Result.put (a.images @ 1, 2)
    end

    window_middle: ARRAY[IMAGE] is
    local
        a: FMA_FRAMESET
    once
        !!Result.make (1, 2)
        !!a.make ("client/fleet-view/window-middle-s.fma")
        Result.put (a.images @ 1, 1)
        !!a.make ("client/fleet-view/window-middle-ns.fma")
        Result.put (a.images @ 1, 2)
    end

    window_bottom: ARRAY[IMAGE] is
    local
        a: FMA_FRAMESET
    once
        !!Result.make (1, 2)
        !!Result.make (1, 2)
        !!a.make ("client/fleet-view/window-bottom-s.fma")
        Result.put (a.images @ 1, 1)
        !!a.make ("client/fleet-view/window-bottom-ns.fma")
        Result.put (a.images @ 1, 2)
    end

    --For buttons, image 1 is up, image 2 is down

    all_button: ARRAY[IMAGE] is
    local
        i: INTEGER
        a: FMA_FRAMESET
    once
        !!Result.make (1, 2)
        !!a.make ("client/fleet-view/all-button.fma")
        from i := 1
        until i > 2 loop
            Result.put (a.images @ i, i)
            a.next
            i := i + 1
        end
    end

    close_button: ARRAY[IMAGE] is
    local
        i: INTEGER
        a: FMA_FRAMESET
    once
        !!Result.make (1, 2)
        !!a.make ("client/fleet-view/close-button.fma")
        from i := 1
        until i > 2 loop
            Result.put (a.images @ i, i)
            a.next
            i := i + 1
        end
    end

    --Scrollbar:
    --1 & 2 is up button, both up and down
    --3 is the trough
    --4 & 5 is down button, both up and down

    scrollbar: ARRAY[IMAGE] is
    local
        a: FMA_FRAMESET
    once
        !!Result.make (1, 5)
        !!a.make ("client/fleet-view/scrollbar-up.fma")
        Result.put (a.images @ 1, 1)
        Result.put (a.images @ 2, 2)
        !!a.make ("client/fleet-view/scrollbar-trough.fma")
        Result.put (a.images @ 1, 3)
        !!a.make ("client/fleet-view/scrollbar-down.fma")
        Result.put (a.images @ 1, 4)
        Result.put (a.images @ 2, 5)
    end


end -- class FLEET_VIEW
