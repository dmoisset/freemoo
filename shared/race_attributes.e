class RACE_ATTRIBUTES
    -- Attributes for stock races.

inherit
    PKG_USER

creation make

feature

    load_race(name: STRING) is
    require
        ruler_names /= Void
        homeworlds /= Void
        specials /= Void
        name /= Void
        dummy_name_trap: not name.is_equal(".")
    local
        f: COMMENTED_TEXT_FILE
        ar: ARRAY[STRING]
    do
        pkg_system.open_file("races/" + name)
        create f.make (pkg_system.last_file_open)
        f.read_nonempty_line
        description.put(clone(f.last_line), name)
        f.read_nonempty_line
        homeworlds.put(clone(f.last_line), name)
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
        f.read_nonempty_line
        pictures.put(f.last_line.to_integer, name)
    ensure
        description.has(name)
        homeworlds.has(name)
        ruler_names.has(name)
        specials.has(name)
        pictures.has(name)
    end

feature

    ruler_names: HASHED_DICTIONARY[ARRAY[STRING], STRING]
        -- Ruler name suggestions

    homeworlds: HASHED_DICTIONARY[STRING, STRING]
        -- Homeworld name suggestion

    specials: HASHED_DICTIONARY[ARRAY[STRING], STRING]

    race_names: ARRAY[STRING]

    description: HASHED_DICTIONARY[STRING, STRING]

    pictures: HASHED_DICTIONARY[INTEGER, STRING]

feature {NONE} -- Creation

    make is
    local
        f: COMMENTED_TEXT_FILE
        it: ITERATOR[STRING]
    do
        create race_names.make(1, 0)
        create ruler_names.make
        create specials.make
        create homeworlds.make
        create description.make
        create pictures.make
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

invariant
    race_names.lower = 1
end -- class RACE_ATTRIBUTES
