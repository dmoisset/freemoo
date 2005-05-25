class PLAYER_LIST [P -> PLAYER]

inherit
    PLAYER_CONSTANTS
    STORABLE
    redefine
	dependents
    end

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
    obsolete "If you want to iterate over a PLAYER_LIST, use get_new_iterator"
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

    get_new_iterator: ITERATOR [P] is
    do
        Result := items.get_new_iterator_on_items
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
            available_colors.put_0 (i.item.color-min_color+1)
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

    set_all_state (new_state: INTEGER) is
        -- change state of all players to `new_state'
    require
        new_state.in_range (min_state, max_state)
    local
        i: ITERATOR [P]
    do
        i := items.get_new_iterator_on_items
        from i.start until i.is_off loop
            set_player_state (i.item, new_state)
            i.next
        end
    ensure
        all_in_state (new_state)
    end

feature -- Saving

	hash_code: INTEGER is
	do
		Result := Current.to_pointer.hash_code
	end

feature {STORAGE} -- Saving

    get_class: STRING is "PLAYER_LIST"
    
    fields: ITERATOR[TUPLE[STRING, ANY]] is
	local
	    a: ARRAY[TUPLE[STRING, ANY]]
	do
	    create a.make (1,0)
	    add_to_fields(a, "player", items.get_new_iterator_on_items)
	    Result := a.get_new_iterator
	end
      
    dependents: ITERATOR[STORABLE] is
	do
	    Result := items.get_new_iterator_on_items
	end
	
feature {STORAGE} -- Retrieving
    
    set_primary_keys (elems: ITERATOR [TUPLE [STRING, ANY]]) is
    do
    end

    make_from_storage (elems: ITERATOR [TUPLE [STRING, ANY]]) is
    local
	player: P
    do
	from
	    items.clear
	until elems.is_off loop
	    if elems.item.first.has_prefix("player") then
		player ?= elems.item.second
		items.add(player, player.name)
	    end
	    elems.next
	end
    end
    
feature {NONE} -- Representation

    items: DICTIONARY [P, STRING]

end -- class PLAYER_LIST [P -> PLAYER]
