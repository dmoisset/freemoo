class REPLACEABLE_CONSTRUCTION
--
-- Makes a construction replaceable by other constructions
--

inherit
    PERSISTENT_CONSTRUCTION
        redefine can_be_built_on, cost, make end

create make

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


    cost(c: like colony_type): INTEGER is
    local
        it: ITERATOR[INTEGER]
        replace: BUILDABLE_CONSTRUCTION
    do
        Result := base_cost
        from
            it := replaces.get_new_iterator
        until
            it.is_off
        loop
            if c.constructions.has(it.item) then
                replace ?= c.constructions.item(it.item)
                check replace /= Void end
                Result := Result - replace.base_cost
            end
            it.next
        end
    end

    add_replacement(replacement: INTEGER) is
    do
        replacements.add(replacement)
    ensure
        replacements.has(replacement)
    end

    add_replaces(replace: INTEGER) is
    do
        replaces.add(replace)
    ensure
        replaces.has(replace)
    end

feature {NONE} -- Auxiliar

    replacements: HASHED_SET[INTEGER]
        -- Constructions that replace this one

    replaces: HASHED_SET[INTEGER]
        -- Constructions this construction replaces

feature {NONE} -- Creation

    make(new_name: STRING; new_id: INTEGER) is
    do
        create replacements.make
        create replaces.make
        Precursor(new_name, new_id)
        replacements.add(id)
    end

invariant

    replaces /= Void
    replacements /= Void
        -- Remember to call make_replaceable from your constructor!

end -- class REPLACEABLE_CONSTRUCTION
