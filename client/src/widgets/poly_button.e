class POLY_BUTTON

inherit
    WINDOW
    rename
        make as window_make
    redefine handle_event, redraw end

creation make

feature {NONE} -- Creation

    make (w: WINDOW; x, y: INTEGER; bg: IMAGE) is
    require
        bg /= Void
    local
        r: RECTANGLE
    do
        r.set_with_size (x, y, bg.width, bg.height)
        window_make (w, r)
        selection := Void
        background := bg
        !!elements.make (1, 0)
    end

feature -- Operations

    add_click_handler (area: RECTANGLE;
                       handler: PROCEDURE [ANY, TUPLE];
                       down: IMAGE) is
        -- Set action to do when clicked on `area' to `handler'.
        -- Display `down' while being cilcked
    local
        e: POLY_BUTTON_ELEMENT
    do
        !!e.make (area, handler, down)
        elements.add_last (e)
    end

feature {NONE} -- Representation

    elements: ARRAY [POLY_BUTTON_ELEMENT]
        -- Clickable element descriptions

    background: IMAGE
        -- Appearance while not pressed

    element_at (x, y: INTEGER): POLY_BUTTON_ELEMENT is
    local
        i: ITERATOR [POLY_BUTTON_ELEMENT]
    do
        i := elements.get_new_iterator
        from i.start until i.is_off or Result /= Void loop
            if i.item.area.has (x, y) then
                Result := i.item
            end
            i.next
        end
    end

feature -- Redefined features

    handle_event (event: EVENT) is
    local
        b: EVENT_MOUSE_BUTTON
        m: EVENT_MOUSE_MOVE
        n: EVENT_MOUSE_NOTIFY
    do
        Precursor (event)
        if not event.handled then
            b ?= event
            n ?= event
            m ?= event
            if b /= Void and then b.state then
                selection := element_at (b.x, b.y)
                request_redraw_all
            elseif b /= Void and then not b.state and selection /= Void then
                selection.handler.call ([])
                selection := Void
                request_redraw_all
            end
            if n /= Void and selection /= Void then
                selection := Void
                request_redraw_all
            end
            if m /= Void and selection /= Void then
                if not selection.area.has (m.x, m.y) then
                    selection := Void
                    request_redraw_all
                end
            end
        end
    end

    redraw (area: RECTANGLE) is
    do
        if selection = Void then
            show_image (background, 0, 0, area)
        else
            show_image (selection.image, 0, 0, area)
        end
        Precursor (area)
    end

feature {NONE} -- Internal

    selection: POLY_BUTTON_ELEMENT
        -- element pointed and down, Void if none

invariant
    valid_selection: selection = Void or else elements.fast_has (selection)

end -- class POLY_BUTTON