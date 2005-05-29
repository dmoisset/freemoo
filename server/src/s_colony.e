class S_COLONY
    
inherit
    COLONY
    redefine 
	owner, location, shipyard
    end
    STORABLE
    rename
	hash_code as id
    redefine
	dependents, primary_keys
    end
    
creation make
    
feature -- Redefined features
    
    location: S_PLANET
    
    owner: S_PLAYER
    
    shipyard: S_SHIP

feature {STORAGE} -- Saving

    get_class: STRING is "COLONY"
	
    fields: ITERATOR[TUPLE[STRING, ANY]] is
    do
	Result := (<<["producing", producing],
		     ["owner", owner],
		     ["location", location]
		     >>).get_new_iterator
    end
    
    primary_keys: ITERATOR[TUPLE[STRING, ANY]] is
    do
	Result := (<<["id", id] >>).get_new_iterator
    end
    

    dependents: ITERATOR[STORABLE] is
    do
	Result := (<<owner, location>>).get_new_iterator
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
	i: reference INTEGER
    do
	from
	until elems.is_off loop
	    if elems.item.first.is_equal("id") then
		i ?= elems.item.second
		id := i
	    elseif elems.item.first.is_equal("producing") then
		i ?= elems.item.second
		producing := i
	    elseif elems.item.first.is_equal("owner") then
		owner ?= elems.item.second
	    elseif elems.item.first.is_equal("location") then
		location ?= elems.item.second
	    end
	    elems.next
	end
    end
	 
end -- class S_COLONY

