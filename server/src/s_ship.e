class S_SHIP
    
inherit
    SHIP
    redefine creator end
    STORABLE
    rename
	hash_code as id
    redefine
	dependents, primary_keys
    end
    
creation make
    
feature
    
    creator: S_PLAYER
    
feature {STORAGE} -- Saving
    
    get_class: STRING is "SHIP"
    
    fields_array: ARRAY[TUPLE[STRING, ANY]] is
	-- Array for `fields'
    do
	Result :=<<["creator", creator],
		   ["owner", owner],
		   ["size", size],
		   ["picture", picture],
		   ["is_stealthy", is_stealthy]
		   >>
    end
    
    fields: ITERATOR[TUPLE[STRING, ANY]] is
    do
	Result := fields_array.get_new_iterator
    end
    
    primary_keys: ITERATOR[TUPLE[STRING, ANY]] is
    do
	Result := (<<["id", id] >>).get_new_iterator
    end
    

    dependents: ITERATOR[STORABLE] is
    do
	Result := (<<creator, owner>>).get_new_iterator
    end
	
feature {STORAGE} -- Retrieving
   
    
    set_primary_keys (elems: ITERATOR [TUPLE [STRING, ANY]]) is
    local
	i: reference INTEGER
    do
	from
	until elems.is_off loop
	    if elems.item.first.is_equal("id") then
		i ?= elems.item.second
		id := i
	    end
	    elems.next
	end
    end
    
    make_from_storage (elems: ITERATOR [TUPLE [STRING, ANY]]) is
    local
	b: reference BOOLEAN
	i: reference INTEGER
	unknown_tag: BOOLEAN
    do
	from
	until elems.is_off or unknown_tag loop
	    if elems.item.first.is_equal("creator") then
		creator ?= elems.item.second
	    elseif elems.item.first.is_equal("owner") then
		owner ?= elems.item.second
	    elseif elems.item.first.is_equal("size") then
		i ?= elems.item.second
		size := i
	    elseif elems.item.first.is_equal("picture") then
		i ?= elems.item.second
		picture := i
	    elseif elems.item.first.is_equal("is_stealthy") then
		b ?= elems.item.second
		is_stealthy := b
	    else
		unknown_tag := true
	    end
	    if not unknown_tag then
		elems.next
	    end
	end
    end
	 
end -- class S_SHIP
