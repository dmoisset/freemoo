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

    last_built: CONSTRUCTION

    last_ship: SHIP_CONSTRUCTION

    item, infix "@"(id: INTEGER): like last_built is
    require
        has(id)
    do
        Result := constructions @ id
    end

    has(id: INTEGER): BOOLEAN is
        -- Do we know how to build `id's ?
    do
        Result := constructions.has(id)
    end

    get_new_iterator: ITERATOR[like last_built] is
    do
        Result := constructions.get_new_iterator_on_items
    end

    count: INTEGER is
    do
        Result := constructions.count
    end

feature {NONE} -- Representation

    constructions: HASHED_DICTIONARY[like last_built, INTEGER]

feature -- Operations

    add_by_id(id: INTEGER) is
    require
        not has(id)
        id.in_range(product_min, product_max)
        id /= product_none
        id /= product_starship -- starships are added with a design
    local
        const: like last_built
        prod: BASIC_PRODUCTIVE_CONSTRUCTION
    do
        inspect id
        when product_colony_ship then
            create last_ship.make_colony_ship
            last_built := last_ship
        when product_housing then
            create {ONGOING_CONSTRUCTION} const.make(product_housing, l("Housing"))
            last_built := const
        when product_trade_goods then
            create {ONGOING_CONSTRUCTION} const.make(product_trade_goods, l("Trade Goods"))
            last_built := const
        when product_automated_factory then
            create prod.make(l("Automated Factory"), product_automated_factory)
            prod.set_cost(60)
            prod.set_maintenance(1)
            prod.set_industry(1, 5)
            last_built := prod
        when product_robo_mining_plant then
            create prod.make(l("Robo Mining Plant"), product_robo_mining_plant)
            prod.set_cost(150)
            prod.set_maintenance(2)
            prod.set_industry(2, 10)
            last_built := prod
        when product_deep_core_mine then
            create prod.make(l("Deep Core Mine"), product_deep_core_mine)
            prod.set_cost(250)
            prod.set_maintenance(3)
            prod.set_industry(3, 15)
            last_built := prod
        when product_astro_university then
            create prod.make(l("Astro University"), product_astro_university)
            prod.set_cost(200)
            prod.set_maintenance(4)
            prod.set_farming(1, 0)
            prod.set_industry(1, 0)
            prod.set_science(1, 0)
            last_built := prod
        when product_research_laboratory then
            create prod.make(l("Research Laboratory"), product_research_laboratory)
            prod.set_cost(60)
            prod.set_maintenance(1)
            prod.set_science(1, 5)
            last_built := prod
        when product_supercomputer then
            create prod.make(l("Planetary Supercomputer"), product_supercomputer)
            prod.set_cost(150)
            prod.set_maintenance(2)
            prod.set_science(2, 10)
            last_built := prod
        when product_autolab then
            create prod.make(l("Autolab"), product_autolab)
            prod.set_cost(200)
            prod.set_maintenance(3)
            prod.set_science(0, 30)
            last_built := prod
        when product_galactic_cybernet then
            create prod.make(l("Galactic Cybernet"), product_galactic_cybernet)
            prod.set_cost(250)
            prod.set_maintenance(3)
            prod.set_science(3, 15)
            last_built := prod
        when product_hidroponic_farm then
            create prod.make(l("Hidroponic Farm"), product_hidroponic_farm)
            prod.set_cost(60)
            prod.set_maintenance(2)
            prod.set_farming(0, 2)
            last_built := prod
        when product_subterranean_farms then
            create prod.make(l("Subterranean Farms"), product_subterranean_farms)
            prod.set_cost(150)
            prod.set_maintenance(4)
            prod.set_farming(0, 4)
            last_built := prod
        when product_weather_controller then
            create prod.make(l("Weather Controller"), product_weather_controller)
            prod.set_cost(200)
            prod.set_maintenance(3)
            prod.set_farming(2, 0)
            last_built := prod
        end
        constructions.add(last_built, id)
    ensure
        last_built.id = id
    end

end -- class CONSTRUCTION_BUILDER
