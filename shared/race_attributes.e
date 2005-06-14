class RACE_ATTRIBUTES
	-- Attributes for stock races.
	
inherit
	PKG_USER
	
creation make
	
feature
	
	load_race(name: STRING) is
	require
		ruler_names /= Void
		homeworld_name /= Void
		specials /= Void
		name /= Void
		name_trap: not name.is_equal(".")
	local
		f: COMMENTED_TEXT_FILE
		ar: ARRAY[STRING]
	do
		pkg_system.open_file("races/" + name)
		create f.make (pkg_system.last_file_open)
		f.read_nonempty_line
		description.put(clone(f.last_line), name)
		f.read_nonempty_line
		homeworld_name.put(clone(f.last_line), name)
		from
			f.read_nonempty_line
			create ar.make(1, 0)
		until f.last_line.is_equal(".") loop
			ar.add_last(clone(f.last_line))
			f.read_nonempty_line
		end
		ruler_names.put(ar, name)
		from
			f.read_nonempty_line
			create ar.make(1, 0)
		until f.last_line.is_equal(".") loop
			ar.add_last(clone(f.last_line))
			f.read_nonempty_line
		end
		specials.put(ar, name)
	ensure
		description.has(name)
		homeworld_name.has(name)
		ruler_names.has(name)
		specials.has(name)
	end
	
feature

	ruler_names: DICTIONARY[ARRAY[STRING], STRING]
		-- Ruler name suggestions
	
	homeworld_name: DICTIONARY[STRING, STRING]
		-- Homeworld name suggestion
	
	specials: DICTIONARY[ARRAY[STRING], STRING]
	
	race_names: ARRAY[STRING]
	
	description: DICTIONARY[STRING, STRING]
	
	
feature {NONE} -- Creation

	make is
	local
		f: COMMENTED_TEXT_FILE
		it: ITERATOR[STRING]
	do
		create race_names.make(1, 0)
		create ruler_names.make
		create specials.make
		create homeworld_name.make
		create description.make
        pkg_system.open_file ("races/races")
        !!f.make (pkg_system.last_file_open)
		from
			f.read_nonempty_line
		until
			f.last_line.is_equal(".")
		loop
			race_names.add_last(clone(f.last_line))
			f.read_nonempty_line
		end
		from
			it := race_names.get_new_iterator
		until it.is_off loop
			load_race(it.item)
			it.next
		end
	end

end -- class RACE_ATTRIBUTES
