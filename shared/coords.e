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
	
end -- class COORDS
