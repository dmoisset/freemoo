class COLONY

inherit
    UNIQUE_ID
    redefine set_id end
    GETTEXT
    PRODUCTION_CONSTANTS
    COLONIZER
    redefine owner end

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
        producing := o.known_constructions @ product_trade_goods
        create ship_factory
        create farming.with_threshold (0.001)
        create industry.with_threshold (0.001)
        create science.with_threshold (0.001)
        create money.with_threshold (0.001)
        create morale.make
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
        producing.id = product_trade_goods
    end

feature -- Access

    producing: CONSTRUCTION
        -- Item being produced

    produced: INTEGER
        -- Accumulated production for `producing'

    has_bought: BOOLEAN
        -- Has the item being produced already been bought this turn?

    buying_price: INTEGER is
        -- How much cach needs to be payed to complete current production
    local
        total_prod: INTEGER
    do
        total_prod := producing.cost(Current)
        if produced > total_prod // 2 then
            Result := (total_prod - produced) * 2
        elseif produced > total_prod // 4 then
            Result := (total_prod - produced) * 3
        else
            Result := (total_prod - produced) * 4
        end
    end

    buy is
    require
        buying_price <= owner.money
        producing.is_buyable
        produced < producing.cost(Current)
    do
        owner.update_money(-buying_price)
        produced := producing.cost(Current)
        has_bought := True
    end

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
        Result := ((2000 * populators.count * (maxpop - populators.count))
                                             / maxpop).sqrt.rounded
        -- Consider racial modifiers
        Result := Result * (100 + owner.race.population_growth) // 100
        -- Consider Advances
        -- ... (Microbiotics, Universal Antidote)...
        -- Consider constructions
        if constructions.has(product_cloning_center) then
            Result := Result + 100
        end
        -- Consider events
        Result := Result + extra_population_growth
        -- Consider Housing Production
        if producing.id = product_housing then
            Result := Result + (industry.total *
                               (25 * (maxpop - populators.count) /
                                     (maxpop * populators.count)).sqrt).rounded
        end
        -- Consider Leader Ability
        -- Consider Missing Food
        Result := Result - 50 * (food_starvation + industry_starvation)
        -- Limit to colony's maximum population
        Result := Result.min(maxpop * 1000 - population)
    end

    max_population: INTEGER is
        -- Colony's maximum population, in population units.
        -- Takes players maximum population for the planet and considers
        -- constructions and biodiversity.
    do
        Result := owner.max_population_on(location)

        -- Consider constructions
        if constructions.has(product_biospheres) then
            Result := Result + 2
        end
        -- For if tolerant, aquatic, subterranean beasts have invaded our colony
        Result := Result.max(populators.count)
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
        if location.climate = location.climate_toxic then
            Result := 1.5
        elseif location.climate = location.climate_barren or
               location.climate = location.climate_radiated then
            Result := 1.25
        else
            Result := 1
        end
    end

    food_starvation: INTEGER is
        -- Only makes sense after recalculate_production
    do
        if not owner.race.lithovore then
            Result := (food_consumption - farming.total.rounded.to_real).ceiling.max(0)
        end
    end

    industry_starvation: INTEGER is
        -- Only makes sense after recalculate_production
    do
        if not owner.race.lithovore then
            Result := (industry_consumption - industry.total.rounded.to_real).floor.max(0)
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
        androids: ARRAY[INTEGER]
        organic_factor: DOUBLE
    do
        farming.clear
        industry.clear
        science.clear
        money.clear
        recalculate_morale
        create census.make(task_farming, task_science)
        create androids.make(task_farming, task_science)
        food_consumption := 0
        industry_consumption := 0
        -- Population Units (production and consumption)
        from
            pop_it := populators.get_new_iterator_on_items
        until
            pop_it.is_off
        loop
            census.put((census @ pop_it.item.task) + 1, pop_it.item.task)
            if pop_it.item.is_android then
                androids.put((androids @ pop_it.item.task) + 1, pop_it.item.task)
            end
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
        if census @ task_farming > 0 then
            organic_factor := (census @ task_farming - androids @ task_farming) / (census @ task_farming)
            farming.add((farming.total * morale.total.to_real *
                             0.01 * organic_factor).to_real, l("Morale Bonus"))
        end
        if census @ task_industry > 0 then
            organic_factor := (census @ task_industry - androids @ task_industry) / (census @ task_industry)
            industry.add((industry.total * morale.total.to_real *
                             0.01 * organic_factor).to_real, l("Morale Bonus"))
        end
        if census @ task_science > 0 then
            organic_factor := (census @ task_science - androids @ task_science) / (census @ task_science)
            science.add((science.total * morale.total.to_real *
                              0.01 * organic_factor).to_real, l("Morale Bonus"))
        end
        money.add(money.total * morale.total.to_real * 0.01, l("Morale Bonus"))
        -- Government Bonus
        farming.add(farming.total * owner.race.food_multiplier.to_real *
                                                    0.01, l("Government Bonus"))
        industry.add(industry.total * owner.race.industry_multiplier.to_real *
                                                    0.01, l("Government Bonus"))
        science.add(science.total * owner.race.science_multiplier.to_real *
                                                    0.01, l("Government Bonus"))
        -- Leader Bonus
        -- Populators pollute
        per_populator_pollution := ((industry.total.rounded // 2 -
            (location.size - location.plsize_min + 1)).max(0) / populators.count).to_real
        from
            pop_it := populators.get_new_iterator_on_items
        until pop_it.is_off loop
            pop_it.item.pollute
            pop_it.next
        end
        -- Buildings clean Up Pollution
        from
            const_it := constructions.get_new_iterator_on_items
        until
            const_it.is_off
        loop
            const_it.item.clean_up_pollution(Current)
            const_it.next
        end
        -- Buildings fixed production and maintenance
        from
            const_it := constructions.get_new_iterator_on_items
        until
            const_it.is_off
        loop
            const_it.item.produce_fixed(Current)
            money.add(-(const_it.item.maintenance(Current).to_real *
                                      maintenance_factor), l("Maintenance"))
            const_it.next
        end
        -- Gold and Gem deposits specials
        if location.special = location.plspecial_gold then
            money.add(5, l("Gold Deposits"))
        elseif location.special = location.plspecial_gems then
            money.add(10, l("Gems Deposits"))
        end
        -- Generate money in a second loop, so's that surplus industry
        -- and food are already known
        from
            pop_it := populators.get_new_iterator_on_items
        until pop_it.is_off loop
            pop_it.item.generate_money
            pop_it.next
        end
        -- Buildings' money
        from
            const_it := constructions.get_new_iterator_on_items
        until
            const_it.is_off
        loop
            const_it.item.generate_money(Current)
            const_it.next
        end
    end

    recalculate_morale is
    local
        it: ITERATOR[CONSTRUCTION]
    do
        morale.clear
        -- Unification ignores all morale bonuses
        if owner.race.government /= owner.race.government_unification then
            -- Missing capitol
            if not owner.has_capitol then
                morale.add(-(owner.race.nocapitol_penalty), l("Missing Capitol"))
            end
            -- Missing barracks (removed later if there's a barrack among our constructions
            morale.add(-(owner.race.nobarracks_penalty), l("No marine barracks"))
            -- Consider buildings
            from
                it := constructions.get_new_iterator_on_items
            until
                it.is_off
            loop
                it.item.affect_morale(Current)
                it.next
            end
            -- Consider government bonus (Imperium...)
            -- .. Consider morale techs (Virtual Reality Network, Psionics)...
            -- .. Consider biodiversity...
            -- Consider leader bonus...
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
        if (food_starvation > 0 or industry_starvation > 0) and new_population > 1000 then
            owner.add_summary_message(create {TURN_SUMMARY_ITEM_STARVATION}.make(id,
                 food_starvation, industry_starvation))
        end
        if constructions.has(product_capitol) and new_population < 1000 then
            -- The capital never starves to death!
            new_population := 1000
        end
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
        produced := produced + (industry.total - industry_consumption).rounded.max(0)
        if producing.is_buyable then
            if produced >= producing.cost(Current) then
                produced := produced - producing.cost(Current)
                producing.build(Current)
                owner.add_summary_message(create {TURN_SUMMARY_ITEM_PRODUCED}.make(id,
                    producing.id, producing.name))
                set_producing(product_trade_goods)
            end
        else
            produced := 0
        end
        -- Reset 'has_bought' flag
        has_bought := False
        -- Contribute money to the race's treasury
        owner.update_money(money.total.rounded)
        -- Contribute research to the race's development
        owner.update_research(science.total.rounded)
    end

    remove is
        -- Remove self from the game
    do
        from
        variant
            constructions.count
        until
            constructions.is_empty
        loop
            constructions.item(constructions.lower).take_down(Current)
        end
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
    require owner.known_constructions.has(newproducing)
    do
        producing := owner.known_constructions @ newproducing
    ensure
        producing.id = newproducing
    end

    clear_shipyard is
        -- Clear the shipyard
    do
        shipyard := Void
    ensure
        shipyard = Void
    end

feature {POPULATION_UNIT} -- Operations for populators

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

    per_populator_pollution: REAL
        -- Non-tolerant population units produce this much pollution every turn.

feature {GALAXY} -- Scanning

    scan(alienfleet: FLEET; alienship: like shipyard): BOOLEAN is
        -- Returns True if this colony picks up `alienship' with it's 
        -- scanners.  `alienship' is part of `alienfleet'
    require
        alienfleet.has_ship(alienship.id)
    do
        if scanner_range = 0 then
            recalculate_scanner_range
        end

        if owner.race.omniscient then
            Result := True
        else
            if location.orbit_center |-| alienfleet < (scanner_range + alienship.size - alienship.ship_size_frigate).to_real then
                Result := True
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
        -- Indeces are task_farming through task_science

    build_ship(sh: like shipyard) is
    require
        sh /= Void
        sh.owner = owner
    do
        shipyard := sh
    ensure
        shipyard = sh
    end

feature -- Auxiliary for colony quick population

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

feature -- Android construction, colonist transportation

    receive(pop: like populator_type) is
    require
        pop /= Void
        pop.fits_on(Current)
    do
        populators.add(pop, pop.id)
        population := population + 1000
    ensure
        populators.has(pop.id)
    end

feature -- Combat

    offensive_power (f: FLEET): INTEGER is
        -- Offensive power, assisted by `f'
    do
        if f /= Void then
            Result := f.offensive_power
        end
        Result := Result + 3
    end

    damage (amount: INTEGER; f: FLEET) is
    local
       p: INTEGER
    do
       if f /= Void then
           p := amount - f.offensive_power - 3
           f.damage (amount)
       else
           p := amount - 3
       end
       from until p < 0 or populators.count = 0 loop
           take_hit
           p := p - 1
       end
    end

    take_hit is
    do
        if populators.count >= 1 then
            populators.remove(populators.item(populators.upper).id)
            population := population - 1000
        end
        if populators.count = 0 then
            remove
        end
    end

feature -- Redefined features

    set_id(new_id: INTEGER) is
    do
        -- set_id can be called from within our constructor,
        -- so we can't count on invariants
        if owner /= Void then
            if owner.colonies.has(id) then
                owner.remove_colony(Current)
            end
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

    terraformed: INTEGER

    terraform_to(new_climate: INTEGER) is
    require
        new_climate.in_range(location.climate_min, location.climate_max)
    do
        terraformed := terraformed + 1
        location.set_climate(new_climate)
        preclimate := new_climate
            -- Once terraformed, losing your radiation
            -- shield won't revert the planet to radiated
    ensure
        terraformed = old terraformed + 1
        location.climate = new_climate
    end

    set_preclimate is
    do
        preclimate := location.climate
    end

    set_pregrav is
    do
        pregrav := location.gravity
    ensure
        pregrav = location.gravity
    end

invariant
    shipyard /= Void implies shipyard.owner = owner
    population // 1000 = populators.count
    populators /= Void
    producing /= Void
    producing.id >= product_min -- producing can have an id > product_max
    constructions /= Void
    location /= Void
    farming /= Void
    industry /= Void
    science /= Void
    money /= Void
    morale /= Void
    owner /= Void
end -- class COLONY
