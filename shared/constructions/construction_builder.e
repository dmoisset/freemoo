class CONSTRUCTION_BUILDER
--
-- Contains a set of constructions; can create new
-- constructions just with their id.  This class concentrates all the 
-- special cases for construction creation, and works as a player's main
-- construction repository
--

inherit
    PRODUCTION_CONSTANTS
    GETTEXT

creation
    make

feature {NONE} -- Creation

    make is
    do
        create constructions.make
    end

feature -- Access

    last_added: CONSTRUCTION

    last_ongoing: ONGOING_CONSTRUCTION

    last_productive: BASIC_PRODUCTIVE_CONSTRUCTION

    last_ship: SHIP_CONSTRUCTION

    has(id: INTEGER): BOOLEAN is
    do
        Result := constructions.has(id)
    end

    item, infix "@"(id: INTEGER): like last_added is
    do
        Result := constructions @ id
    end

    get_new_iterator: ITERATOR[like last_added] is
    do
        Result := constructions.get_new_iterator_on_items
    end

    count: INTEGER is
    do
        Result := constructions.count
    end

feature {NONE} -- Representation

    constructions: HASHED_DICTIONARY[like last_added, INTEGER]

feature -- Operations

    add_by_id(id: INTEGER) is
    require
        not has(id)
        id.in_range(product_min, product_max)
        id /= product_none
        id /= product_starship -- starships are added with a design
    do
        inspect id
        when product_colony_ship then
            create last_ship.make_colony_ship
            last_added := last_ship
        when product_housing then
            create last_ongoing.make(l("Housing"), product_housing)
            last_added := last_ongoing
        when product_trade_goods then
            create last_ongoing.make(l("Trade Goods"), product_trade_goods)
            last_added := last_ongoing
        when product_automated_factory then
            create last_productive.make(l("Automated Factory"), product_automated_factory)
            last_productive.set_cost(60)
            last_productive.set_maintenance(1)
            last_productive.set_industry(1, 5)
            last_added := last_productive
        when product_robo_mining_plant then
            create last_productive.make(l("Robo Mining Plant"), product_robo_mining_plant)
            last_productive.set_cost(150)
            last_productive.set_maintenance(2)
            last_productive.set_industry(2, 10)
            last_added := last_productive
        when product_deep_core_mine then
            create last_productive.make(l("Deep Core Mine"), product_deep_core_mine)
            last_productive.set_cost(250)
            last_productive.set_maintenance(3)
            last_productive.set_industry(3, 15)
            last_added := last_productive
        when product_astro_university then
            create last_productive.make(l("Astro University"), product_astro_university)
            last_productive.set_cost(200)
            last_productive.set_maintenance(4)
            last_productive.set_farming(1, 0)
            last_productive.set_industry(1, 0)
            last_productive.set_science(1, 0)
            last_added := last_productive
        when product_research_laboratory then
            create last_productive.make(l("Research Laboratory"), product_research_laboratory)
            last_productive.set_cost(60)
            last_productive.set_maintenance(1)
            last_productive.set_science(1, 5)
            last_added := last_productive
        when product_supercomputer then
            create last_productive.make(l("Planetary Supercomputer"), product_supercomputer)
            last_productive.set_cost(150)
            last_productive.set_maintenance(2)
            last_productive.set_science(2, 10)
            last_added := last_productive
        when product_autolab then
            create last_productive.make(l("Autolab"), product_autolab)
            last_productive.set_cost(200)
            last_productive.set_maintenance(3)
            last_productive.set_science(0, 30)
            last_added := last_productive
        when product_galactic_cybernet then
            create last_productive.make(l("Galactic Cybernet"), product_galactic_cybernet)
            last_productive.set_cost(250)
            last_productive.set_maintenance(3)
            last_productive.set_science(3, 15)
            last_added := last_productive
        when product_hidroponic_farm then
            create last_productive.make(l("Hidroponic Farm"), product_hidroponic_farm)
            last_productive.set_cost(60)
            last_productive.set_maintenance(2)
            last_productive.set_farming(0, 2)
            last_added := last_productive
        when product_subterranean_farms then
            create last_productive.make(l("Subterranean Farms"), product_subterranean_farms)
            last_productive.set_cost(150)
            last_productive.set_maintenance(4)
            last_productive.set_farming(0, 4)
            last_added := last_productive
        when product_weather_controller then
            create last_productive.make(l("Weather Controller"), product_weather_controller)
            last_productive.set_cost(200)
            last_productive.set_maintenance(3)
            last_productive.set_farming(2, 0)
            last_added := last_productive
        end
        constructions.add(last_added, id)
    ensure
        last_added.id = id
    end

    add_starship_design(design: like starship_type) is
    require
        design /= Void
    do
        create last_ship.make_starship(design)
        constructions.add(last_ship, last_ship.id)
        last_added := last_ship
    end

feature {NONE} -- Anchors

    starship_type: STARSHIP

end -- class CONSTRUCTION_BUILDER
