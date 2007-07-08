class SCROLLED_LIST[E]
--
-- A list of items with an optional scrollbar.
--

inherit
    WINDOW
    rename
        make as window_make
    end

create
    make

feature -- Indexing

    lower: INTEGER is
        -- Lower index bound
    do
        Result := items.lower
    end

    upper: INTEGER is
        -- Upper index bound
    do
        Result := items.upper
    end

    valid_index(index: INTEGER): BOOLEAN is
    do
        Result := items.lower <= index and then index <= items.upper
    ensure
        Result = (lower <= index and then index <= upper)
    end

feature -- Counting

    count: INTEGER is
        -- Number of available indeces
    do
        Result := items.count
    ensure
        Result = upper - lower + 1
    end

    is_empty: BOOLEAN is
        -- Is the list empty?
    do
        Result := items.is_empty
    ensure
        Result = (count = 0)
    end

feature -- Access

    item(i: INTEGER): E is
        -- Item at the corresponding index `i'.
    require
        valid_index(i)
    do
        Result := items @ i
    end

    text(i: INTEGER): STRING is
        -- String for the corresponding item
    require
        valid_index(i)
    do
        Result := texts @ i
    end

    first_item: like item is
        -- The very first item.
    require
        count >= 1
    do
        Result := items.first
    ensure
        Result = item(lower)
    end

    first_text: like text is
        -- The very first text.
    require
        count >= 1
    do
        Result := texts.first
    ensure
        Result = text(lower)
    end

    last_item: like item is
        -- The last item.
    require
        count >= 1
    do
        Result := items.last
    ensure
        Result = item(upper)
    end

    last_text: like text is
        -- The last text.
    require
        count >= 1
    do
        Result := texts.last
    ensure
        Result = text(upper)
    end

feature -- Writing

    put(element: like item; msg: like text; i: INTEGER) is
    require
        valid_index(i)
    do
        items.put(element, i)
        texts.put(msg, i)
        update_widgets
    ensure
        item(i) = element
        text(i) = msg
        count = old count
    end

feature -- Adding

    add_first(element: like item; msg: like text) is
    local
        r: RECTANGLE
    do
        items.add_first(element)
        texts.add_first(msg)
        update_scrollbar
        update_widgets
    ensure
        first_item = element;
        first_text = msg;
        count = 1 + old count;
        lower = old lower;
        upper = 1 + old upper
    end

    add_last(element: like item; msg: like text) is
    local
        r: RECTANGLE
    do
        items.add_last(element)
        texts.add_last(msg)
        update_scrollbar
        update_widgets
    ensure
        last_item = element;
        last_text = msg;
        count = 1 + old count;
        lower = old lower;
        upper = 1 + old upper
    end

    add (element: like item; msg: like text; index: INTEGER) is
      -- Add a new `element' at rank `index' : `count' is increased
      -- by one and range [`index' .. `upper'] is shifted right
      -- by one position.
    require
        index.in_range(lower,upper + 1)
    do
        items.add(element, index)
        texts.add(msg, index)
        update_scrollbar
        update_widgets
    ensure
        item(index) = element;
        text(index) = msg;
        count = 1 + old count;
        upper = 1 + old upper
    end

feature -- Modification

    from_collections(model: COLLECTION[like item]; msgs: COLLECTION[like text]) is
        -- Initialize the current object with the contents of `model'.
    require
        model /= Void
        msgs /= Void
        model.count = msgs.count
    do
        items.clear
        texts.clear
        items.from_collection(model)
        texts.from_collection(msgs)
        update_scrollbar
        update_widgets
    ensure
        count = model.count
    end

feature -- Removing:

    remove_first is
      -- Remove the `first' element.
    require
        not is_empty
    do
        items.remove_first
        texts.remove_first
        update_scrollbar
        update_widgets
    ensure
        upper = old upper;
        count = old count - 1;
        lower = old lower + 1 xor upper = old upper - 1
    end

    remove_at (index: INTEGER) is
        -- Remove the item at position `index'. Followings items
        -- are shifted left by one position.
    require
        valid_index(index)
    do
        items.remove(index)
        texts.remove(index)
        update_scrollbar
        update_widgets
    ensure
        count = old count - 1;
        upper = old upper - 1
    end

    remove_last is
      -- Remove the `last' element.
    require
        not is_empty
    do
        items.remove_last
        texts.remove_last
        update_scrollbar
        update_widgets
    ensure
         count = old count - 1;
         upper = old upper - 1
    end

    clear is
        -- Discard all items in order to make it `is_empty'.
    do
        items.clear
        texts.clear
        update_scrollbar
        update_widgets
    ensure
        is_empty
    end

feature -- Other Operations

    set_click_handler(handler: PROCEDURE[ANY, TUPLE[E]]) is
    do
        click_handler := handler
    end

    set_on_enter_handler(handler: PROCEDURE[ANY, TUPLE[E]]) is
    do
        on_enter_handler := handler
    end

    set_on_exit_handler(handler: PROCEDURE[ANY, TUPLE[E]]) is
    do
        on_exit_handler := handler
    end

feature -- Operations on widgets

    set_button_images(i1, i2, i3: IMAGE) is
    require
        i1.height < height
        i2.height < height
        i3.height < height
    do

        b1 := i1
        b2 := i2
        b3 := i3
        labels.do_all(agent remove_window)
        buttons.do_all(agent remove_window)
        update_scrollbar
        update_widgets
    end

    set_up_images(i1, i2, i3: IMAGE) is
    do
        scrollbar.set_first_button_images(i1, i2, i3)
    end

    set_down_images(i1, i2, i3: IMAGE) is
    do
        scrollbar.set_second_button_images(i1, i2, i3)
    end

feature {NONE} -- Creation

    make(w: WINDOW; where: RECTANGLE; scrollbar_location: RECTANGLE; s: RESIZABLE_IMAGE) is
    local
        r: RECTANGLE
    do
        create items.make(1, 0)
        create texts.make(1, 0)
        create labels.make(1, 0)
        create buttons.make(1, 0)
        window_make(w, where)
        create scrollbar.make(Current, scrollbar_location, s)
        scrollbar.set_change_handler(agent update_widgets)
        r.set_with_size(2, 18, scrollbar.width - 4, scrollbar.height - 36)
        scrollbar.set_trough(r)
    ensure
        scrollbar /= Void
    end

feature {NONE} -- Implementation

    scrollbar: V_SCROLLBAR

    b1, b2, b3: IMAGE

    click_handler: PROCEDURE[ANY, TUPLE[like item]]

    on_enter_handler: PROCEDURE[ANY, TUPLE[like item]]

    on_exit_handler: PROCEDURE[ANY, TUPLE[like item]]

    items: ARRAY[like item]

    texts: ARRAY[like text]

    labels: ARRAY[LABEL]

    buttons: ARRAY[BUTTON_IMAGE]

feature {NONE} -- Implementation

    update_scrollbar is
    local
        page_size: INTEGER
    do
        if row_height > 0 then
            page_size := height // row_height
        else
            page_size := 1000
        end
        if page_size + 1 >= items.count then
            scrollbar.hide
        else
            scrollbar.set_limits(items.lower, items.upper, page_size)
            scrollbar.set_increments(1, page_size)
            scrollbar.show
        end
    end

    update_widgets is
    local
        i, j, ypos, start, stop: INTEGER
        r: RECTANGLE
        button: BUTTON_IMAGE
        label: LABEL
    do
        if b1 /= Void and b2 /= Void and b3 /= Void then
            if scrollbar.visible then
                start := scrollbar.value
                stop := scrollbar.value + scrollbar.page_size
            else
                start := items.lower
                stop := items.upper
            end
            from
                j := labels.lower
                i := start
            until
                i > stop
            loop
                check
                    items.valid_index(i)
                    texts.valid_index(i)
                end
                if j > labels.upper then
                    if labels.is_empty then
                        ypos := 0
                    else
                        ypos := labels.last.location.y2 + 2
                    end
                    r.set_with_size(0, ypos, width - scrollbar.width, row_height - 2)
                    create label.make(Current, r, texts @ i)
                    create button.make(Current, 0, ypos, b1, b2, b3)
                    labels.add_last(label)
                    buttons.add_last(button)
                else
                    labels.item(j).set_text(texts @ i)
                end
                check
                    labels.valid_index(j)
                    buttons.valid_index(j)
                end
                buttons.item(j).set_click_handler(agent handle_click(items @ i))
                buttons.item(j).set_on_enter_handler(agent handle_on_enter(items @ i))
                buttons.item(j).set_on_exit_handler(agent handle_on_exit(items @ i))
                j := j + 1
                i := i + 1
            end
        end
        from
            -- Remove excess buttons and labels
        variant
            labels.upper
        until
            j > labels.upper
        loop
            labels.item(j).remove
            buttons.item(j).remove
            labels.remove(j)
            buttons.remove(j)
        end
    ensure
        texts.count >= labels.count
    end

    remove_window(w: WINDOW) is
    do
        w.remove
    end

    row_height: INTEGER is
    do
        if b1 = Void or b2 = Void or b3 = Void then
            Result := 0
        else
            Result := b1.height.max(b2.height).max(b3.height) + 2
        end
    end

    handle_click(element: like item) is
    do
        if click_handler /= Void then
            click_handler.call([element])
        end
    end

    handle_on_enter(element: like item) is
    do
        if on_enter_handler /= Void then
            on_enter_handler.call([element])
        end
    end

    handle_on_exit(element: like item) is
    do
        if on_exit_handler /= Void then
            on_exit_handler.call([element])
        end
    end

invariant

    items.lower = texts.lower
    items.count = texts.count
    labels.count = buttons.count
    labels.lower = 1
    buttons.lower = 1
end -- class SCROLLED_LIST
