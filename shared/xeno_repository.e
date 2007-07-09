class XENO_REPOSITORY
    -- Kind of a singleton class to access races.
    -- Our internal data structure is a once method,
    -- so if you modify this instance all other xeno_repositories
    -- are updated.

inherit
    GETTEXT

feature

    item (id: INTEGER):  like race_type is
        -- Retrieve a spescific race with it's id.
    do
        if races.has(id) then
            Result := races@id
        else
            create Result.make
            Result.set_id(id)
            races.add(Result, id)
        end
    ensure
        Result.id = id
    end

    by_name (name: STRING): like race_type is
        -- Search for a spescific race by name.  Use 'item' if you can.
    local
        it: ITERATOR [like race_type]
    do
        from
            it := races.get_new_iterator_on_items
        until
            it.is_off or Result /= Void
        loop
            if it.item.name.is_equal (name) then
                Result := it.item
            end
            it.next
        end
    end

    add(race: like race_type) is
    do
        if not races.has(race.id) then
            races.add(race, race.id)
        end
    end

feature {GAME} -- Operations

    generate_knowledge is
    local
        natives, androids: like race_type
    do
        create natives.make
        natives.set_picture(14)
        natives.set_name(l("Natives"))
        natives.set_attribute("farming_bonus=2")
        create androids.make
        androids.set_picture(13)
        androids.set_name(l("Android"))
        androids.set_attribute("farming_bonus=3")
        androids.set_attribute("industry_bonus=3")
        androids.set_attribute("science_bonus=3")
        androids.set_attribute("tolerant")
        add(androids)
        add(natives)
    end

feature {NONE} -- Representation

    races: HASHED_DICTIONARY[like race_type, INTEGER] is
    once
        create Result.make
    end

feature {NONE} -- Anchors

    race_type: RACE

end -- class XENO_REPOSITORY
