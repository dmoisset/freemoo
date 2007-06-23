class POPULATION_UNIT
inherit
    UNIQUE_ID
    GETTEXT
    PRODUCTION_CONSTANTS
    STRING_FORMATTER

creation make

feature -- Access

    race: RACE
        -- Race of this populator

    colony: COLONY
        -- Colony on which this population unit lives

    turns_to_assimilation: INTEGER
        -- Number of turns missing for this populator to be assimilated

    task: INTEGER
        -- Task this populator is doing.  Must be one of the task_xxxx constants

    able_farmer: BOOLEAN is
    do
        Result := single_task = task_farming or
                  (single_task = task_none and then
                    colony.location.climate > colony.location.climate_barren)
    end

    able_worker: BOOLEAN is
    do
        Result := single_task = task_industry or
                  single_task = task_none
    end

    able_scientist: BOOLEAN is
    do
        Result := single_task = task_science or
                  single_task = task_none
    end

    able(t: INTEGER): BOOLEAN is
    require
        t.in_range(task_farming, task_science)
    do
        Result := t = task_farming and then able_farmer or else
                  t = task_industry and then able_worker or else
                  t = task_science and then able_scientist
    end

    production_factor: REAL is
        -- A value that considers unhealthy (strange gravity) environments
        -- to penalize production
    do
        Result := production_factor_array.item(race.homeworld_gravity,
                                               colony.location.gravity)
    end

    single_task: INTEGER
        -- Races that are only good at one thing (like natives)
        -- indicate their task here

    is_android: BOOLEAN
        -- True for androids

    fits_on(c: like colony): BOOLEAN is
    do
        -- FIXME!! This should check if this populator really fits on
        -- the colony!
        Result := True
    end

feature {NONE} -- Auxiliar for `production_factor'

    production_factor_array: ARRAY2[REAL] is
        --     LG  NG  HG < Planet gravity
        -- LG   1 .75  .5
        -- NG .75   1 .75
        -- HG .75   1   1
        --  ^ Race's homeworld gravity
    once
        create Result.make(-1, 1, colony.location.grav_min, colony.location.grav_max)
        Result.put(1,    -1, colony.location.grav_lowg)
        Result.put(0.75, -1, colony.location.grav_normalg)
        Result.put(0.5,  -1, colony.location.grav_highg)
        Result.put(0.75,  0, colony.location.grav_lowg)
        Result.put(1,     0, colony.location.grav_normalg)
        Result.put(0.75,  0, colony.location.grav_highg)
        Result.put(0.75,  1, colony.location.grav_lowg)
        Result.put(1,     1, colony.location.grav_normalg)
        Result.put(1,     1, colony.location.grav_highg)
    end

feature -- Operation

    generate_money is
    local
        item: REAL
        total: REAL
    do
        if not is_android then
            colony.money.add(1, l("Taxes Collected"))
            if race.money_bonus > 0 then
                colony.money.add(race.money_bonus.to_real * 0.5, format(l("~1~ Bonus"), <<race.name>>))
            elseif race.money_bonus < 0 then
                colony.money.add(race.money_bonus.to_real * 0.5, format(l("~1~ Penalty"), <<race.name>>))
            end
            -- Fantastic traders
            if race.fantastic_trader then
                colony.money.add(total, l("Fantastic Traders"))
            end
        end
        -- Surplus food
        item := ((colony.farming.total - colony.food_consumption).max(0) /
                    colony.populators.count.to_real) / 2
        colony.money.add(item, l("Food Surplus"))
        total := item
        -- Trade goods
        if colony.producing.id = product_trade_goods then
            item := (colony.industry.total - colony.industry_consumption).max(0) /
                    colony.populators.count.to_real / 2
            colony.money.add(item, l("Trade Goods"))
            total := total + item
        end
    end

    pollute is
    do
        if not race.tolerant then
            colony.industry.add(-(colony.per_populator_pollution), l("Pollution Penalty"))
        end
    end

    produce is
    do
        inspect
            task
        when task_farming then
            colony.farming.add(((colony.location.planet_farming @
                    colony.location.climate).to_real * production_factor).rounded.to_real,
                    l("Produced by farmers"))
            if race.farming_bonus /= 0 then
                colony.farming.add(race.farming_bonus.to_real,
                                   format(l("~1~ Bonus"), <<race.name>>))
            end
        when task_industry then
            colony.industry.add(((colony.location.planet_industry @
                    colony.location.mineral).to_real * production_factor).rounded.to_real,
                    l("Produced by workers"))
            if race.industry_bonus /= 0 then
                colony.industry.add(race.industry_bonus.to_real,
                                    format(l("~1~ Bonus"), <<race.name>>))
            end
        when task_science then
            if is_android then
                colony.science.add(3, l("Android scientists"))
            else
                colony.science.add(3, l("Produced by scientists"))
                if race.science_bonus /= 0 then
                    colony.science.add(race.science_bonus.to_real,
                                       format(l("~1~ Bonus"), <<race.name>>))
                end
            end
            if colony.location.special = colony.location.plspecial_artifacts then
                colony.science.add(2, l("Ancient Artifacts"))
            end
        else
            check unexpected_task: False end
        end
        -- Eat!
        if is_android then
            colony.consume_industry(1)
        elseif race.cybernetic then
            colony.consume_food(0.5)
            colony.consume_industry(0.5)
        else
            colony.consume_food(1)
        end
    end

    set_task(t: INTEGER) is
    require
        t.in_range(task_farming, task_science)
        t = task_farming implies able_farmer
        t = task_industry implies able_worker
        t = task_science implies able_scientist
    do
        task := t
    ensure
        task = t
    end

    set_single_task(t: INTEGER) is
    require
        t.in_range(task_none, task_science)
    do
        single_task := t
        if t.in_range(task_farming, task_science) then
            task := t
        end
    ensure
        single_task = t
        t.in_range(task_farming, task_science) implies task = t
    end

    set_is_android(android: BOOLEAN) is
    do
        is_android := android
    ensure
        is_android = android
    end

feature {NONE} -- Creation

    make(r: like race; c: like colony) is
    require
        r /= Void
        c /= Void
    do
        make_unique_id
        race := r
        colony := c
        task := task_farming
        if not able_farmer then
            task := task_industry
        end
        single_task := task_none
    end

feature -- Serialization

    serialize_on (s: SERIALIZER2) is
    do
        s.add_tuple (<<id.box, race.id.box, turns_to_assimilation.to_boolean.box,
                     (task - task_farming).box, (single_task - task_farming).box,
                     is_android.box>>)
    end

    unserialize_from (s: UNSERIALIZER) is
    do
        s.get_boolean
        turns_to_assimilation := s.last_boolean.to_integer
        s.get_integer
        task := s.last_integer + task_farming
        s.get_integer
        single_task := s.last_integer + task_farming
        s.get_boolean
        is_android := s.last_boolean
    end

invariant
    race /= Void
    colony /= Void
    task.in_range(task_farming, task_science)
    task = task_farming implies able_farmer
    task = task_industry implies able_worker
    task = task_science implies able_scientist
    single_task.in_range(task_none, task_science)
end -- class POPULATION_UNIT
