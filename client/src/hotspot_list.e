class HOTSPOT_LIST
-- Hotspots are rectangles that have an associated integer, usually 
-- a UNIQUE_ID.  We want to be able to find which hotspot, if any,
-- is at certain (x, y) position.  We sometimes need a fast_key_at,
-- but without the 'fast_occurrences = 1' pre.
	
inherit DICTIONARY[RECTANGLE, INTEGER]
	redefine fast_key_at end

creation
	make, with_capacity
	
feature

	item_at_xy(x, y: INTEGER): ITERATOR[RECTANGLE] is
		-- Returns an iterator to the first hotspot that contains 
		-- (`x',`y'), or an iterator that is_off if no hotspot does.
		-- Can be optimized with two-dimension bisection-search.
	do
		from
			Result := get_new_iterator_on_items
		until
			Result.is_off or else Result.item.has(x, y)
		loop
			Result.next
		end
	end
	
	fast_key_at(v: RECTANGLE): INTEGER is
		-- Can be optimized comparing one component at a time
	require else
		fast_occurrences(v) >= 1
	local
		i: INTEGER
	do
		from
			i := lower
		until
			item(i) = v
		loop
			i := i + 1
		end
		Result := key(i)
	end

end -- class HOTSPOT_LIST

