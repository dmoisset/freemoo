class GAME_STATUS
    -- Public status of the server

inherit
	STORABLE

creation
    make, make_with_options

feature {NONE} -- Creation

    make is
    do
    end

    make_with_options (options: SERVER_OPTIONS) is
    do
        open_slots       := options.int_options     @ "maxplayers"
        galaxy_size      := options.enum_options    @ "galaxysize"
        galaxy_age       := options.enum_options    @ "galaxyage"
        start_tech_level := options.enum_options    @ "starttech"
        tactical_combat  := options.bool_options.has ("tactical")
        random_events    := options.bool_options.has ("randomevs")
        antaran_attacks  := options.bool_options.has ("antarans")
    end

feature -- Access (server status)

    open_slots: INTEGER
        -- slots open for players

    started: BOOLEAN
        -- True after game has began

    finished: BOOLEAN
        -- True when game is closed

    date: INTEGER
        -- Turns since the beginning of the game

feature -- Access (game rules)

    galaxy_size: INTEGER
        -- From 0 (small) to 3 (huge)

    galaxy_age: INTEGER
        -- From -1 (organic rich) to +1 (mineral rich)

    start_tech_level: INTEGER
        -- From 0 (pre-warp) to 2 (advanced)

    tactical_combat, random_events, antaran_attacks: BOOLEAN

feature -- Operations

    fill_slot is
        -- fill_one_game_slot
    require
        open_slots > 0
        not finished
    do
        open_slots := open_slots-1
    end

    start is
        -- Begin game
    require
        open_slots = 0
        not finished
    do
        started := True
    end

    finish is
        -- End game
    require
        started
    do
        finished := True
    end

    next_date is
    require
        not finished
    do
        date := date + 1
    end

feature -- Saving

	hash_code: INTEGER is
	do
 		Result := Current.to_pointer.hash_code
	end

feature {STORAGE} -- Saving

	get_class: STRING is "GAME_STATUS"

	fields: ITERATOR[TUPLE [STRING, ANY]] is
	do
		Result := (<< ["open_slots", open_slots],
					 ["started", started],
					 ["finished", finished],
					 ["date", date],
					 ["galaxy_size", galaxy_size],
					 ["galaxy_age", galaxy_age],
					 ["start_tech_level", start_tech_level],
					 ["tactical_combat", tactical_combat],
					 ["random_events", random_events],
					 ["antaran_attacks", antaran_attacks]
					 >>).get_new_iterator
	end
	
feature {STORAGE} -- Retrieving
    
    set_primary_keys (elems: ITERATOR [TUPLE [STRING, ANY]]) is
    do
    end
    
    make_from_storage (elems: ITERATOR [TUPLE [STRING, ANY]]) is
    local
	b: reference BOOLEAN
	i: reference INTEGER
    do
	from
	until elems.is_off 
	loop
	    if elems.item.first.is_equal("open_slots") then
		i ?= elems.item.second
		open_slots := i
	    elseif elems.item.first.is_equal("started") then
		b ?= elems.item.second
		started := b
	    elseif elems.item.first.is_equal("finished") then
		b ?= elems.item.second
		finished := b
	    elseif elems.item.first.is_equal("date") then
		i ?= elems.item.second
		date := i
	    elseif elems.item.first.is_equal("galaxy_size") then
		i ?= elems.item.second
		galaxy_size := i
	    elseif elems.item.first.is_equal("galaxy_age") then
		i ?= elems.item.second
		galaxy_age := i
	    elseif elems.item.first.is_equal("start_tech_level") then
		i ?= elems.item.second
		start_tech_level := i
	    elseif elems.item.first.is_equal("tactical_combat") then
		b ?= elems.item.second
		tactical_combat := b
	    elseif elems.item.first.is_equal("random_events") then
		b ?= elems.item.second
		random_events := b
	    elseif elems.item.first.is_equal("antaran_attacks") then
		b ?= elems.item.second
		antaran_attacks := b
	    end
	    elems.next
	end
    end

invariant
    started implies open_slots = 0
    finished implies started
    open_slots >= 0
    galaxy_size.in_range (0, 3)
    galaxy_age.in_range (-1, 1)
    start_tech_level.in_range (0, 2)
    date >= 0

end -- class GAME_STATUS
