class S_GAME_STATUS
    -- Public status of the server

inherit
    GAME_STATUS
    redefine
        fill_slot, start, finish, next_date
    end
    STORABLE
    SERVICE
    redefine subscription_message end

creation
    make_with_options

feature -- Redefined features

    subscription_message (service_id: STRING): STRING is
    local
        s: SERIALIZER2
    do
        !!s.make
        s.add_tuple (<<open_slots.box, finished.box, started.box,
                     galaxy_size.box, galaxy_age.box, start_tech_level.box,
                     tactical_combat.box, random_events.box,
                     antaran_attacks.box, date.box>>)
        Result := s.serialized_form
    end

feature -- Access

    id: STRING is "game_status"

feature -- Operations

    fill_slot is
    do
        Precursor
        update_clients
    end

    start is
    do
        Precursor
        update_clients
    end

    finish is
    do
        Precursor
        update_clients
    end

    next_date is
    do
        Precursor
        update_clients
    end

    update_clients is
    do
        send_message (id, subscription_message (id))
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
	b: REFERENCE [BOOLEAN]
	i: REFERENCE [INTEGER]
    do
	from
	until elems.is_off 
	loop
	    if elems.item.first.is_equal("open_slots") then
		i ?= elems.item.second
		open_slots := i.item
	    elseif elems.item.first.is_equal("started") then
		b ?= elems.item.second
		started := b.item
	    elseif elems.item.first.is_equal("finished") then
		b ?= elems.item.second
		finished := b.item
	    elseif elems.item.first.is_equal("date") then
		i ?= elems.item.second
		date := i.item
	    elseif elems.item.first.is_equal("galaxy_size") then
		i ?= elems.item.second
		galaxy_size := i.item
	    elseif elems.item.first.is_equal("galaxy_age") then
		i ?= elems.item.second
		galaxy_age := i.item
	    elseif elems.item.first.is_equal("start_tech_level") then
		i ?= elems.item.second
		start_tech_level := i.item
	    elseif elems.item.first.is_equal("tactical_combat") then
		b ?= elems.item.second
		tactical_combat := b.item
	    elseif elems.item.first.is_equal("random_events") then
		b ?= elems.item.second
		random_events := b.item
	    elseif elems.item.first.is_equal("antaran_attacks") then
		b ?= elems.item.second
		antaran_attacks := b.item
	    end
	    elems.next
	end
    end

end -- class S_GAME_STATUS
