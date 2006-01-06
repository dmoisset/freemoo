class C_COLONY

inherit
    COLONY
    redefine make, set_task, remove, location end
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
        pop_count, pop_id, const_count, const_id, product: INTEGER
        race: RACE
        new_populators: HASHED_DICTIONARY[POPULATION_UNIT, INTEGER]
        new_population: INTEGER
        populator: POPULATION_UNIT
        design: C_STARSHIP
        builder: C_CONSTRUCTION_BUILDER
    do
        create builder
        create s.start (msg)
        s.get_integer
        product := s.last_integer + product_min
        if product > product_max then
            create design.make(owner)
            design.set_id(product - product_max)
            design.unserialize_completely_from(s)
        end
        if owner.known_constructions.has(product) then
            set_producing(product)
        else
            if product <= product_max then
                builder.construction_by_id(product)
            else
                builder.construction_from_design(design)
            end
            producing := builder.last_built
        end
        -- so much code just to ensure that...
        check producing.id = product end
        s.get_integer
        produced := s.last_integer
        s.get_boolean
        has_bought := s.last_boolean
        s.get_integer
        new_population := s.last_integer
        s.get_integer
        terraformed := s.last_integer
        s.get_integer
        pop_count := s.last_integer
        s.get_integer
        const_count := s.last_integer
        create new_populators.make
        from
        until
            pop_count = 0
        loop
            s.get_integer
            pop_id := s.last_integer
            s.get_integer
            race := server.xeno_repository.item(s.last_integer)
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
        from
            constructions.clear
        until
            const_count = 0
        loop
            s.get_integer
            const_id := s.last_integer + product_min
            check const_id.in_range(product_min, product_max) end
            constructions.add(owner.known_constructions @ (const_id), const_id)
            const_count := const_count - 1
        end

        if populators.count > 0 then
            recalculate_production
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

feature -- Redefined features

    location: C_PLANET

feature -- Signals

    changed: SIGNAL_1 [C_COLONY]

end -- class C_COLONY
