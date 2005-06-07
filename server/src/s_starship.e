class S_STARSHIP
    
inherit
    S_SHIP
    redefine creator, fields_array, make_from_storage end
    STARSHIP
    redefine creator end
    
creation make
    
feature
    creator: S_PLAYER
    
feature
    
    fields_array: ARRAY[TUPLE[STRING, ANY]] is
    do
	Result := Precursor
	Result.add_last(["name", name])
    end
    
    make_from_storage (elems: ITERATOR [TUPLE [STRING, ANY]]) is
    do
	from
	until elems.is_off loop
	    Precursor(elems)
	    if not elems.is_off then
		if elems.item.first.is_equal("name") then
		    name ?= elems.item.second
		end
	    end
	    elems.next
	end
    end
	 

end -- class S_STARSHIP
