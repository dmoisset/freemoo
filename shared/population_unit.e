class POPULATION_UNIT
inherit
    GETTEXT
    STRING_FORMATTER

creation make

feature -- Access

    race: RACE
        -- Race of this populator

    colony: COLONY
        -- Colony on which this population unit lives

    turns_to_assimilation: INTEGER
        -- Number of turns missing for this populator to be assimilated

    task_farming, task_industry, task_science: INTEGER is unique
    
    task: INTEGER
        -- Task this populator is doing.  Must be one of the task_xxxx constants

    able_farmer: BOOLEAN is
    do
        Result := colony.location.climate > colony.location.climate_barren
    end

    able_worker: BOOLEAN is
    do
        Result := True
    end

    able_scientist: BOOLEAN is
    do
        Result := True
    end

feature -- Operation

    produce is
    do
        print ("In produce!%N")
        inspect
            task
        when task_farming then
            colony.farming.add(colony.location.planet_farming @ colony.location.climate, l("Produced by farmers"))
            print ("Produced farming: " + (colony.location.planet_farming @ colony.location.climate).to_string + "%N")
            if race.farming_bonus /= 0 then
                colony.farming.add(race.farming_bonus, format(l("~1~ Bonus"), <<race.name>>))
                print ("Produced racial bonus: " + race.farming_bonus.to_string + "%N")
            end
        when task_industry then
            colony.industry.add(colony.location.planet_industry @ colony.location.mineral, l("Produced by workers"))
            if race.industry_bonus /= 0 then
                colony.industry.add(race.industry_bonus, format(l("~1~ Bonus"), <<race.name>>))
            end
        when task_science then
            colony.science.add(3, l("Produced by scientists"))
            if race.science_bonus /= 0 then
                colony.science.add(race.science_bonus, format(l("~1~ Bonus"), <<race.name>>))
            end
            if colony.location.special = colony.location.plspecial_artifacts then
                colony.science.add(2, l("Ancient Artifacts"))
            end
        else
            check unexpected_task: False end
        end
        colony.money.add(1, l("Taxes Collected"))
        if race.money_bonus > 0 then
            colony.money.add(race.money_bonus * 0.5, format(l("~1~ Bonus"), <<race.name>>))
        elseif race.money_bonus < 0 then
            colony.money.add(race.money_bonus * 0.5, format(l("~1~ Penalty"), <<race.name>>))
        end
    end

    set_task(t: INTEGER) is
    require
        t = task_farming implies able_farmer
        t = task_industry implies able_worker
        t = task_science implies able_scientist
    do
        task := t
    ensure
        task = t
    end

feature {NONE} -- Creation

    make(r: RACE; c: COLONY) is
    require
        r /= Void
        c /= Void
    do
        race := r
        colony := c
        task := task_farming
        if not able_farmer then
            task := task_industry
        end
    end

feature -- Serialization

    serialize_on (s: SERIALIZER2) is
    do
        s.add_tuple (<<turns_to_assimilation.to_boolean.box, (task - task_farming).box>>)
    end

    unserialize_from (s: UNSERIALIZER) is
    do
        s.get_boolean
        turns_to_assimilation := s.last_boolean.to_integer
        s.get_integer
        task := s.last_integer + task_farming
    end

invariant
    race /= Void
    colony /= Void
    task.in_range(task_farming, task_science)
    task = task_farming implies able_farmer
    task = task_industry implies able_worker
    task = task_science implies able_scientist
end -- class POPULATION_UNIT
