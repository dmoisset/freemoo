class PLAYER_LIST [P -> PLAYER]

inherit
    PLAYER_CONSTANTS

creation make

feature {NONE} -- Creation

    make is
    do
        !!items.make
    end

feature -- Access

    has (name: STRING): BOOLEAN is
    do
        Result := items.has (name)
    ensure
        Result = items.has (name)
    end

    infix "@" (key: STRING): P is
    require
        has (key)
    do
        Result := items @ key
    ensure
        Result = items @ key
    end

    names: ARRAY [STRING] is
    local
        sort: COLLECTION_SORTER [STRING]
    do
        !!Result.make (1, 0)
        items.key_map_in (Result)
        sort.sort (Result)
    end

    count: INTEGER is
    do
        Result := items.count
    end

    capacity: INTEGER is
    do
        Result := max_color - min_color + 1
    end

    all_in_state (state: INTEGER): BOOLEAN is
        -- All players are in given `state'?
    local
        i: ITERATOR [P]
    do
        i := items.get_new_iterator_on_items
        from
            Result := True
            i.start
        until i.is_off or not Result loop
            Result := (i.item.state = state)
            i.next
        end
    end

feature -- Operations

    add (item: P) is
    require
        item /= Void
        count < capacity
        not has (item.name)
    local
        available_colors: BIT_STRING
        color: INTEGER
        i: ITERATOR [P]
    do
        !!available_colors.make (max_color-min_color+1)
        available_colors.set_all

        -- List available colors
        i := items.get_new_iterator_on_items
        from i.start until i.is_off loop
            available_colors.put_0 (i.item.color_id-min_color+1)
            i.next
        end
        -- Get first free color
        from color := 1 until available_colors.item (color) loop
            color := color + 1
        end
        item.set_color (color+min_color-1)

        -- Add to list
        items.add (item, item.name)
    end

    set_player_state (p: PLAYER; new_state: INTEGER) is
        -- change `p' state to `new_state'
    require
        new_state.in_range (min_state, max_state)
        p /= Void
        has (p.name)
    do
        p.set_state (new_state)
    ensure
        p.state = new_state
    end

feature {NONE} -- Representation

    items: DICTIONARY [P, STRING]

end -- class PLAYER_LIST [P <- PLAYER]