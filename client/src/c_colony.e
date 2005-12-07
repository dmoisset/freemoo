class C_COLONY

inherit
    COLONY
    redefine make end
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
        pop_count: INTEGER
        race: RACE
        new_populators: ARRAY[POPULATION_UNIT]
        new_population: INTEGER
        populator: POPULATION_UNIT
    do
        !!s.start (msg)
        s.get_integer
        producing := s.last_integer + product_min
        s.get_integer
        new_population := s.last_integer
        s.get_integer
        create new_populators.make(1,0)
        print (s.last_integer.to_string + " populators.%N")
        from
            pop_count := s.last_integer
        until
            pop_count = 0
        loop
            print ("Creating 1 population unit...%N")
            s.get_integer
            race := server.player_list.item_with_race_id(s.last_integer).race
            create populator.make(race, Current)
            populator.unserialize_from(s)
            new_populators.add_last(populator)
            pop_count := pop_count - 1
        end
        population := new_population
        populators := new_populators
        changed.emit(Current)
    end

feature -- Signals

    changed: SIGNAL_1 [C_COLONY]

end -- class C_COLONY
