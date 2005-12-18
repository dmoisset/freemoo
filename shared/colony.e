class COLONY

inherit
    UNIQUE_ID
    redefine set_id end
    GETTEXT
    PRODUCTION_CONSTANTS

creation make

feature {NONE} -- Creation

    make (p: like location; o: like owner) is
        -- Build `o' colony on planet `p'
    require
        p /= Void
        o /= Void
    local
        first_populator: like populator_type
    do
        make_unique_id
        producing := product_none
        create ship_factory
        create farming.make
        create industry.make
        create science.make
        create money.make
        create morale.make
        morale.add(o.race.morale_bonus, l("Government Morale"))
        -- .. Consider morale techs (Virtual Reality Network, Psionics)...
        create constructions.make
        create populators.make
        location := p
        p.set_colony (Current)
        owner := o
        o.add_colony(Current)
        create first_populator.make(o.race, Current)
        populators.add(first_populator, first_populator.id)
        population := 1000
    ensure
        location = p
        p.colony = Current
        producing = product_none
    end

feature -- Access

    producing: INTEGER
        -- Item being produced, one of the `product_xxxx' constants.

    starship_design: like shipyard
        -- The starship we're building or refitting

    location: PLANET
        -- location of the colony

    owner: PLAYER
        -- Player that controls the colony

    shipyard: SHIP
        -- Placeholder for last built ship.  Game should come and fetch it.

    ship_factory: SHIP_FACTORY
        -- Abstract factory for ships

    population: INTEGER
        -- Colony's population in Kinhabitants (thousandths of population units)

    population_growth: INTEGER is
        -- Population growth per turn, in KInhabitants
    local
        maxpop: INTEGER
    do
        maxpop := max_population
        Result := ((2000 * (maxpop - populators.count)) /
                            (populators.count * maxpop)).sqrt.rounded
        -- Consider racial modifiers
        Result := Result * (100 + owner.race.population_growth) // 100
        -- Consider Advances
        -- ... (Microbiotics, Universal Antidote)...
        -- Consider constructions and events
        Result := Result + extra_population_growth
        -- Consider Housing Production
        if producing = product_housing then
            Result := Result + (industry.total *
                               (25 * (maxpop - populators.count) /
                                     (maxpop * populators.count)).sqrt).rounded
        end
        -- Consider Leader Ability
        -- Consider Missing Food
        if not owner.race.lithovore then
            Result := Result - 50 * ((food_consumption - farming.total).ceiling.max(0) +
                                     (industry_consumption - industry.total).floor.max(0))
        end
    end

    max_population: INTEGER is
        -- Colony's maximum population, in population units.
        -- Takes players maximum population for the planet and considers
        -- constructions and biodiversity.
    local
        aliens: REAL
        subterranean: BOOLEAN
        pop_it: ITERATOR[POPULATION_UNIT]
    do
        Result := owner.max_population_on(location)
        -- Consider constructions
        Result := Result + extra_max_population
        -- Consider biodiversity
        subterranean := owner.race.subterranean
        from
            pop_it := populators.get_new_iterator_on_items
        until
            pop_it.is_off
        loop
            if pop_it.item.race.subterranean /= subterranean then
                aliens := aliens + 1
            end
            pop_it.next
        end
        if populators.count > 0 then
            -- This coming code breaks if populators.count = 0
            -- It happens when a colony dies of starvation, on the client, just
            -- before the colony is removed
            if subterranean then
                Result := Result - (location.subterranean_maxpop_bonus *
                                    aliens / populators.count).ceiling
            else
                Result := Result + (location.subterranean_maxpop_bonus *
                                    aliens / populators.count).floor
            end
        end
    end

    populators: HASHED_DICTIONARY[like populator_type, INTEGER]
        -- This colony's populators.  There's one for each 1000 KInhabitants.

    constructions: HASHED_DICTIONARY[CONSTRUCTION, INTEGER]
        -- This colony's constructions.

    farming, industry, science, money: EXPLAINED_ACCUMULATOR[REAL]
        -- A detailed explanation of this colony's per-turn production.
        -- These values are recalculated in `recalculate_production',
        -- beware of using them when outdated or uninitialized.

    food_consumption, industry_consumption: REAL
        -- Food and Industry the populators eat per turn.  These values
        -- are recalculated with `recalculate_production',
        -- beware of reading them when outdated or uninitialized.

    morale: EXPLAINED_ACCUMULATOR[INTEGER]
        -- A detailed explanation of this colony's morale status.  This
        -- value *isn't* recalculated with `recalculate_production', and
        -- persists from turn to turn.  It's modified with diferent actions,
        -- like constructions, technologies or enemy blocades.

    maintenance_factor: REAL is
        -- A value that considers harsh environments to increase maintenance
        -- costs.
    do
        if location.cimate = location.climate_toxic then
            Result := 1.5
        elseif location.climate = location.climate_barren or
               location.climate = location.climate_radiated then
            Result := 1.25
        else
            Result := 1
        end
    end

feature -- Operations

    recalculate_production is
        -- Update farming, industry, science, money, food_consumption and
        -- industry_consumption, considering colonists production, government
        -- type, constructions, biodiversity, pollution, leaders and the
        -- kitchen's sink.
    local
        pop_it: ITERATOR[POPULATION_UNIT]
        const_it: ITERATOR[CONSTRUCTION]
    do
        print ("in recalculate_production%N")
        farming.clear
        industry.clear
        science.clear
        money.clear
        create census.make(task_farming, task_science)
        food_consumption := 0
        industry_consumption := 0
        -- Population Units (production and consumption)
        from
            pop_it := populators.get_new_iterator_on_items
        until
            pop_it.is_off
        loop
            census.put((census @ pop_it.item.task) + 1, pop_it.item.task)
            pop_it.item.produce
            pop_it.next
        end
        -- Buildings' proportional
        from
            const_it := constructions.get_new_iterator_on_items
        until
            const_it.is_off
        loop
            const_it.item.produce_proportional(Current)
            const_it.next
        end
        -- Morale Bonus
        farming.add(farming.total * morale.total * 0.01, l("Morale Bonus"))
        industry.add(industry.total * morale.total * 0.01, l("Morale Bonus"))
        science.add(science.total * morale.total * 0.01, l("Morale Bonus"))
        money.add(money.total * morale.total * 0.01, l("Morale Bonus"))
        -- Government Bonus
        farming.add(farming.total * owner.race.food_multiplier * 0.01, l("Government Bonus"))
        industry.add(industry.total * owner.race.industry_multiplier * 0.01, l("Government Bonus"))
        science.add(science.total * owner.race.science_multiplier * 0.01, l("Government Bonus"))
        -- Leader Bonus
        -- Pollution
        if not owner.race.tolerant then
            industry.add(-((industry.total.rounded // 2 - (location.size -
                 location.plsize_min + 1)).max(0)), l("Pollution Penalty"))
        -- Clean Up Pollution
            from
                const_it := constructions.get_new_iterator_on_items
            until
                const_it.is_off
            loop
                const_it.item.clean_up_pollution(Current)
                const_it.next
            end
        end
        -- Buildings fixed production
        from
            const_it := constructions.get_new_iterator_on_items
        until
            const_it.is_off
        loop
            const_it.item.produce_fixed(Current)
            const_it.next
        end
        -- Generate money in a second loop, so's that surplus industry
        -- and food are already known
        from
            pop_it := populators.get_new_iterator_on_items
        until pop_it.is_off loop
            pop_it.item.generate_money
            pop_it.next
        end
    end

    new_turn is
        -- Update population, production, and build finished constructions.
    local
        new_population: INTEGER
        new_populator: like populator_type
    do
        recalculate_production
        new_population := population + population_growth
        from
            -- First create population_units and then add to maintain class
            -- invariants in colony and population_unit
        until
            new_population // 1000 = population // 1000
        loop
            if new_population // 1000 > population // 1000 then
                create new_populator.make(owner.race, Current)
                populators.add(new_populator, new_populator.id)
                population := population + 1000
            else
                populators.remove(populators.item(populators.upper).id)
                population := population - 1000
            end
        end
        population := new_population
        -- check if production is enough to build before doing this next thing...
        if producing = product_starship then
            -- starship_design should be set just before setting producing
            -- to product_starship.  We're not doing this yet.
            ship_factory.create_starship(owner)
            ship_factory.last_starship.set_name("Enterprise")
            starship_design := ship_factory.last_starship
            shipyard := starship_design
        elseif producing /= product_none then
            owner.known_constructions.item(producing).build(Current)
        end
        producing := product_none
    end

    remove is
        -- Remove self from the game
    do
        location.set_colony (Void)
        owner.remove_colony(Current)
    ensure
        location.colony = Void
        not owner.colonies.has(id)
    end

feature -- Operations

    set_task(pops: HASHED_SET[POPULATION_UNIT]; task: INTEGER) is
        -- Set all populators in `pops' to do the given `task'
    local
        pop_it: ITERATOR[POPULATION_UNIT]
    do
        from
            pop_it := pops.get_new_iterator
        until
            pop_it.is_off
        loop
            pop_it.item.set_task(task)
            pop_it.next
        end
    end

    set_producing (newproducing: INTEGER) is
        -- Start building a brand new `newproducing'
    require newproducing.in_range(product_min, product_max)
    do
        producing := newproducing
        print ("Colony: Started building a " + newproducing.to_string + "%N")
    ensure
        producing = newproducing
    end

    clear_shipyard is
        -- Clear the shipyard
    do
        shipyard := Void
    ensure
        shipyard = Void
    end

    consume_food(amount: REAL) is
        -- Increase food_consumption by `amount'
    do
        food_consumption := food_consumption + amount
    ensure
        food_consumption = old food_consumption + amount
    end

    consume_industry(amount: REAL) is
        -- Increase industry_consumption by `amount'
    do
        industry_consumption := industry_consumption + amount
    ensure
        industry_consumption = old industry_consumption + amount
    end

feature {GALAXY} -- Scanning

    scan(alienfleet: FLEET; alienship: like shipyard): BOOLEAN is
        -- Returns true if this colony picks up `alienship' with it's 
        -- scanners.  `alienship' is part of `alienfleet'
    require
        alienfleet.has_ship(alienship.id)
    do
        if scanner_range = 0 then
            recalculate_scanner_range
        end

        if owner.race.omniscient then
            Result := true
        else
            if location.orbit_center |-| alienfleet < scanner_range + alienship.size - alienship.ship_size_frigate then
                Result := true
            end
        end
    end

feature {NONE} -- Auxiliary for scanning

    scanner_range: INTEGER
        -- Scanner range considering all our colony's modifiers.  
        -- Should be reset to 0 after any modification (constructions,
        -- research, etc.).

    recalculate_scanner_range is
        -- Recalculates `scanner_range' considering all our modifiers.
        -- Quite dumb for now...
    do
        scanner_range := 2
    end

feature {CONSTRUCTION} -- Auxiliary for construction production

    census: ARRAY[INTEGER]
        -- Census of farmers, workers and scientists.  It's value is
        -- recalculated with `recalculate_production'.

    build_ship(sh: like shipyard) is
    do
        shipyard := sh
    ensure
        shipyard = sh
    end

feature {EVOLVER} -- Auxiliary for evolving

    add_populator(task: INTEGER) is
    require
        task.in_range(task_farming, task_science)
    local
        pop: like populator_type
    do
        create pop.make(owner.race, Current)
        populators.add(pop, pop.id)
        population := population + 1000
        pop.set_task(task)
    end

feature -- Redefined features

    set_id(new_id: INTEGER) is
    do
        -- set_id can be called from within our constructor,
        -- so we can't count on invariants
        if owner /= Void then
            owner.remove_colony(Current)
            Precursor(new_id)
            owner.add_colony(Current)
        else
            Precursor(new_id)
        end
    end

feature {NONE} -- Anchors

    populator_type: POPULATION_UNIT

feature {CONSTRUCTION} -- Special cases

    preclimate:  INTEGER
        -- Climate to which this colony will return if the radiation shield
        -- is destroyed

    pregrav: INTEGER
        -- Gravity to which this colony will return if gravity generator
        -- is destroyed

    extra_population_growth: INTEGER
        -- Extra population Growth for this colony

    extra_max_population: INTEGER
        -- Increased maximum population for this colony

invariant
    population // 1000 = populators.count
    valid_producing: producing.in_range (product_min, product_max)
--    producing = product_starship implies starship_design /= Void
    populators /= Void
    constructions /= Void
    location /= Void
    farming /= Void
    industry /= Void
    science /= Void
    money /= Void
    morale /= Void
    owner /= Void
end -- class COLONY
