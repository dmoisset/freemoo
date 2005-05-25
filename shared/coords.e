class COORDS
    -- Efective positional

inherit POSITIONAL
	STORABLE

creation
    make_at

feature {NONE}
    make_at(xx, yy:REAL) is
    do
        x:=xx
        y:=yy
    end -- make_at

feature -- Saving

	hash_code: INTEGER is
	do
		Result := Current.to_pointer.hash_code
	end
	
feature {STORAGE} -- Saving
    
    get_class: STRING is "COORDS"
    
    fields: ITERATOR[TUPLE[STRING, ANY]] is
    do
	Result := (<<["x", x], ["y", y]>>).get_new_iterator
    end
    
feature {STORAGE} -- Retrieving
    
    set_primary_keys (elems: ITERATOR [TUPLE [STRING, ANY]]) is
    do
    end
    
    make_from_storage (elems: ITERATOR [TUPLE [STRING, ANY]]) is
    local
	r: reference REAL
    do
	from
	until elems.is_off loop
	    if elems.item.first.is_equal("x") then
		r ?= elems.item.second
		x := r
	    elseif elems.item.first.is_equal("y") then
		r ?= elems.item.second
		y := r
	    end
	    elems.next
	end
    end

	
end -- class COORDS
