deferred class REPLACEABLE_CONSTRUCTION
-- Makes a construction replaceable by other constructions

inherit CONSTRUCTION

feature -- Operations

    can_be_built_on(c: like colony_type): BOOLEAN is
    local
        it: ITERATOR[INTEGER]
    do
        Result := True
        from
            it := replacements.get_new_iterator
        until
            it.is_off or not Result
        loop
            Result := not c.constructions.has(it.item)
            it.next
        end
    end

    add_replacement(replacement: INTEGER) is
    do
        replacements.add(replacement)
    ensure
        replacements.has(replacement)
    end

feature {NONE} -- Auxiliar

    replacements: HASHED_SET[INTEGER]

feature {NONE} -- Creation

    make_replaceable is
    do
        create replacements.make
        replacements.add(id)
    end

invariant

    replacements /= Void
        -- Remember to call make_replaceable from your constructor!

end -- class REPLACEABLE_CONSTRUCTION
