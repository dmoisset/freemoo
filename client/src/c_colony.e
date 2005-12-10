class C_COLONY

inherit
    COLONY
    redefine make, set_task, remove end
    SUBSCRIBER
    CLIENT

creation
    make

feature {NONE} -- Creation

    make (p: like location; o: like owner) is
    do
        Precursor(p, o)
        create changed.make
    end

feature

    on_message (msg: STRING; provider: SERVICE_PROVIDER; service: STRING) is
        -- Action when `msg' arrives from `provider''s `service'
    local
        s: UNSERIALIZER
        pop_count, pop_id: INTEGER
        race: RACE
        new_populators: HASHED_DICTIONARY[POPULATION_UNIT, INTEGER]
        new_population: INTEGER
        populator: POPULATION_UNIT
    do
        !!s.start (msg)
        s.get_integer
        producing := s.last_integer + product_min
        s.get_integer
        new_population := s.last_integer
        s.get_integer
        create new_populators.make
        from
            pop_count := s.last_integer
        until
            pop_count = 0
        loop
            s.get_integer
            pop_id := s.last_integer
            s.get_integer
            race := server.player_list.item_with_race_id(s.last_integer).race
            if populators.has(pop_id) and then (populators @ pop_id).race = race then
                populator := populators @ pop_id
            else
                create populator.make(race, Current)
                populator.set_id(pop_id)
            end
            populator.unserialize_from(s)
            new_populators.add(populator, populator.id)
            pop_count := pop_count - 1
        end
        population := new_population
        populators := new_populators
        if populators.count > 0 then
            changed.emit(Current)
        else
            remove
        end
    end

    set_task(pops: HASHED_SET[POPULATION_UNIT]; task: INTEGER) is
    do
        Precursor(pops, task)
        recalculate_production
        changed.emit(Current)
    end

    remove is
        -- Remove self from the game
    do
        if owner.colonies.has(id) then
            owner.remove_colony(Current)
        end
        location.set_colony (Void)
    end


feature -- Signals

    changed: SIGNAL_1 [C_COLONY]

end -- class C_COLONY
