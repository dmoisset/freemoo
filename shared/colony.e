class COLONY

inherit
    UNIQUE_ID
    redefine set_id end
    GETTEXT

creation make

feature {NONE} -- Creation

    make (p: like location; o: like owner) is
        -- Build `o' colony on planet `p'
    require
        p /= Void
        o /= Void
    local
        first_populator: POPULATION_UNIT
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
        create constructions.make(1, 0)
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
        -- Population growth per turn, in Kinhabitants
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
        if owner.race.cybernetic then
            Result := Result - 50 * ((populators.count // 2 - farming.total.rounded).max(0) +
                                    ((populators.count + 1) // 2 - industry.total.rounded).max(0))
        else
            Result := Result - 50 * (populators.count - farming.total.rounded).max(0)
        end
    end

    max_population: INTEGER is
        -- Colony's maximum population, in population units.
        -- Takes players maximum population for the planet and considers constructions and biodiversity.
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

    populators: HASHED_DICTIONARY[POPULATION_UNIT, INTEGER]

    constructions: ARRAY[CONSTRUCTION]

    farming, industry, science, money: EXPLAINED_ACCUMULATOR[REAL]

    morale: EXPLAINED_ACCUMULATOR[INTEGER]

    recalculate_production is
    local
       pop_it: ITERATOR[POPULATION_UNIT]
       const_it: ITERATOR[CONSTRUCTION]
    do
        print ("in recalculate_production%N")
        farming.clear
        industry.clear
        science.clear
        money.clear
        -- Population Units
        from
            pop_it := populators.get_new_iterator_on_items
        until
            pop_it.is_off
        loop
            pop_it.item.produce
            pop_it.next
        end
        -- Buildings' proportional
        from
            const_it := constructions.get_new_iterator
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
                const_it := constructions.get_new_iterator
            until
                const_it.is_off
            loop
                const_it.item.clean_up_pollution(Current)
                const_it.next
            end
        end
        -- Buildings fixed production
        from
            const_it := constructions.get_new_iterator
        until
            const_it.is_off
        loop
            const_it.item.produce_fixed(Current)
            const_it.next
        end
    end

feature -- Constants

    product_none, product_starship, product_colony_ship,
    product_housing, product_trade_goods,
    product_construction, product_spy: INTEGER is unique
        -- Possible production_items

    product_min: INTEGER is
        -- Minimum valid for `producing'
    do Result := product_none end

    product_max: INTEGER is
        -- Minimum valid for `producing'
    do Result := product_colony_ship end

feature -- Operations

    new_turn is
    local
        new_population: INTEGER
        new_populator: POPULATION_UNIT
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
        inspect
            producing
        when product_none then
            -- Nothing to do this turn
        when product_starship then
            ship_factory.create_starship(owner)
            ship_factory.last_starship.set_name("Enterprise")
            shipyard := ship_factory.last_starship
            set_producing(product_colony_ship)
        when product_colony_ship then
            ship_factory.create_colony_ship(owner)
            shipyard := ship_factory.last_colony_ship
            set_producing(product_starship)
        end
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
    require newproducing.in_range(product_min, product_max)
    do
        producing := newproducing
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
