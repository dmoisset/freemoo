class XENO_REPOSITORY

inherit
    GETTEXT

create
    make, make_with_knowledge

feature

    natives, androids: like race_type

    item(id: INTEGER):  like race_type is
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

    add(race: like race_type) is
    do
        if not races.has(race.id) then
            races.add(race, race.id)
        end
    end

feature {NONE} -- Creation

    make is
    do
        create races.make
    end

feature -- Operations

    generate_knowledge is
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

    races: HASHED_DICTIONARY[like race_type, INTEGER]

feature {NONE} -- Anchors

    race_type: RACE

end -- class XENO_REPOSITORY
