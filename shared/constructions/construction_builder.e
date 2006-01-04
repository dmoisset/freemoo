class CONSTRUCTION_BUILDER
--
-- Can create new constructions just with their id.  This class
-- concentrates all the special cases for construction creation.
--

inherit
    PRODUCTION_CONSTANTS
    GETTEXT

feature -- Access

    last_built: CONSTRUCTION

    last_ongoing: ONGOING_CONSTRUCTION

    last_productive: BASIC_PRODUCTIVE_CONSTRUCTION

    last_shield: CONSTRUCTION_SHIELD

    last_ship: SHIP_CONSTRUCTION

    last_persistent: PERSISTENT_CONSTRUCTION

    last_replaceable: REPLACEABLE_CONSTRUCTION

    last_cleaner: CONSTRUCTION_DEPOLLUTER

feature -- Operations

    construction_by_id(id: INTEGER) is
    require
        id.in_range(product_min, product_max)
        id /= product_starship -- starships are added with a design
    do
        inspect id
        when product_colony_ship then
            create last_ship.make_colony_ship
            last_built := last_ship
        when product_housing then
            create last_ongoing.make(l("Housing"), product_housing)
            last_built := last_ongoing
        when product_none then
            create last_ongoing.make(l("Nothing"), product_none)
            last_built := last_ongoing
        when product_trade_goods then
            create last_ongoing.make(l("Trade Goods"), product_trade_goods)
            last_built := last_ongoing
        when product_automated_factory then
            create last_productive.make(l("Automated Factory"), product_automated_factory)
            last_productive.set_cost(60)
            last_productive.set_maintenance(1)
            last_productive.set_industry(1, 5)
            last_productive.set_description("Aid industry workers in their building of finished products. Generates 5  production and increases the production each worker generates by +1.")
            last_built := last_productive
        when product_robo_mining_plant then
            create last_productive.make(l("Robo Mining Plant"), product_robo_mining_plant)
            last_productive.set_cost(150)
            last_productive.set_maintenance(2)
            last_productive.set_industry(2, 10)
            last_productive.set_description("Automate many difficult tasks, increasing the productivity of industrial workers. Generates 10 production and increases the production each worker  produces by +2.")
            last_built := last_productive
        when product_deep_core_mine then
            create last_productive.make(l("Deep Core Mine"), product_deep_core_mine)
            last_productive.set_cost(250)
            last_productive.set_maintenance(3)
            last_productive.set_industry(3, 15)
            last_productive.set_description("Allows miners to build stable tunnels deep into a planet. Generates 15  production and increases the productivity of each worker by +3 production each.")
            last_built := last_productive
        when product_astro_university then
            create last_productive.make(l("Astro University"), product_astro_university)
            last_productive.set_cost(200)
            last_productive.set_maintenance(4)
            last_productive.set_farming(1, 0)
            last_productive.set_industry(1, 0)
            last_productive.set_science(1, 0)
            last_productive.set_description("Using the most advanced teaching methods available, the efficiency of farmers, workers, and scientists is increased. Each receives a +1 bonus.")
            last_built := last_productive
        when product_research_laboratory then
            create last_productive.make(l("Research Laboratory"), product_research_laboratory)
            last_productive.set_cost(60)
            last_productive.set_maintenance(1)
            last_productive.set_science(1, 5)
            last_productive.set_description("Houses state-of-the-art computer equipment, creating a superior research environment. Generates 5 research points and increases the research each  scientist produces by +1.")
            last_built := last_productive
        when product_supercomputer then
            create last_productive.make(l("Planetary Supercomputer"), product_supercomputer)
            last_productive.set_cost(150)
            last_productive.set_maintenance(2)
            last_productive.set_science(2, 10)
            last_productive.set_description("Supplies researchers with a vast amount of information. Generates 10 research  points and increases the research each scientist produces by +2.")
            last_built := last_productive
        when product_autolab then
            create last_productive.make(l("Autolab"), product_autolab)
            last_productive.set_cost(200)
            last_productive.set_maintenance(3)
            last_productive.set_science(0, 30)
            last_productive.set_description("A completely automated research facility. Generates 30 research points.")
            last_built := last_productive
        when product_galactic_cybernet then
            create last_productive.make(l("Galactic Cybernet"), product_galactic_cybernet)
            last_productive.set_cost(250)
            last_productive.set_maintenance(3)
            last_productive.set_science(3, 15)
            last_productive.set_description("Nearly instantaneous galaxy-wide communications, allowing quick exchange of information and ideas. The cybernet generates 15 research points and each scientist generates +3 research each.")
            last_built := last_productive
        when product_hidroponic_farm then
            create last_productive.make(l("Hidroponic Farm"), product_hidroponic_farm)
            last_productive.set_cost(60)
            last_productive.set_maintenance(2)
            last_productive.set_farming(0, 2)
            last_productive.set_description("An automated, sealed environment in which food can be grown, even on lifeless worlds. It increases the food output of a world by +2 food.")
            last_built := last_productive
        when product_subterranean_farms then
            create last_productive.make(l("Subterranean Farms"), product_subterranean_farms)
            last_productive.set_cost(150)
            last_productive.set_maintenance(4)
            last_productive.set_farming(0, 4)
            last_productive.set_description("An underground cavern system of automated farms. Increases the food output of a planet by +4.")
            last_built := last_productive
        when product_weather_controller then
            create last_productive.make(l("Weather Controller"), product_weather_controller)
            last_productive.set_cost(200)
            last_productive.set_maintenance(3)
            last_productive.set_farming(2, 0)
            last_productive.set_description("Modifies a planet's weather patterns to create a more stable farming environment. Food production is increased by +2 per farmer.")
            last_built := last_productive
        when product_spaceport then
            create last_productive.make(l("Spaceport"), product_spaceport)
            last_productive.set_cost(80)
            last_productive.set_maintenance(1)
            last_productive.set_money(50)
            last_productive.set_description("Site for commercial transactions, increasing the money generation of a colony by +50%%.")
            last_built := last_productive
        when product_stock_exchange then
            create last_productive.make(l("Planetary Stock Exchange"), product_stock_exchange)
            last_productive.set_cost(150)
            last_productive.set_maintenance(2)
            last_productive.set_money(100)
            last_productive.set_description("Increases the revenues earned on a planet by +100%%.")
            last_built := last_productive
        when product_colony_base then
            create {CONSTRUCTION_COLONY_BASE}last_built.make
        when product_gravity_generator then
            create {CONSTRUCTION_GRAVITY_GENERATOR}last_built.make
        when product_terraforming then
            create {CONSTRUCTION_TERRAFORMING}last_built.make
        when product_radiation_shield then
            create last_shield.make(l("Radiation Shield"), product_radiation_shield)
            last_shield.set_cost(80)
            last_shield.set_maintenance(1)
            last_shield.set_shield_power(5)
            last_shield.set_description("Reduces solar and cosmic bombardment so lifeforms can comfortably move about the surface. Radiated climates become Barren.  Reduces damage against a planet by 5 points.")
            last_shield.add_replacement(product_flux_shield)
            last_shield.add_replacement(product_barrier_shield)
            last_built := last_shield
        when product_flux_shield then
            create last_shield.make(l("Planetary Flux Shield"), product_flux_shield)
            last_shield.set_cost(200)
            last_shield.set_maintenance(3)
            last_shield.set_shield_power(10)
            last_shield.set_description("Seals planet in an energy field. Converts Radiated climates into Barren. Reduces damage against the planet 10 points. It replaces any planetary radiation shield already built.")
            last_shield.add_replacement(product_barrier_shield)
            last_shield.add_replaces(product_radiation_shield)
            last_built := last_shield
        when product_barrier_shield then
            create last_shield.make(l("Planetary Barrier Shield"), product_barrier_shield)
            last_shield.set_cost(500)
            last_shield.set_maintenance(5)
            last_shield.set_shield_power(20)
            last_shield.set_description("Seals a planet in an energy field. Converts Radiated climates to Barren climates. Reduces damage against a planet by 20 points. Ground troops and biological weapons cannot pass.")
            last_shield.add_replaces(product_radiation_shield)
            last_shield.add_replaces(product_flux_shield)
            last_built := last_shield
        when product_cloning_center then
            create last_persistent.make(l("Cloning Center"), product_cloning_center)
            last_persistent.set_description("Allows doctors to replace failing or damaged organs, increasing the population growth by +100K each turn as long as the current population is below the planetary maximum.")
            last_persistent.set_cost(100)
            last_persistent.set_maintenance(2)
            last_built := last_persistent
        when product_starbase then
            create last_replaceable.make(l("Star Base"), product_starbase)
            last_replaceable.set_description("Armed orbital platforms used to service military ships.  They are equipped with extensive weaponry, the best available scanner with a +2 scanning range bonus and a star dock capable of building ships larger than destroyers.")
            last_replaceable.set_cost(400)
            last_replaceable.set_maintenance(2)
            last_replaceable.add_replacement(product_battlestation)
            last_replaceable.add_replacement(product_star_fortress)
            last_built := last_replaceable
        when product_battlestation then
            create last_replaceable.make(l("Battlestation"), product_battlestation)
            last_replaceable.set_description("Heavily armed star base, with +4 parsec scanning range bonus. Adds +10%% to the offense of ships in combat around it. Replaces a star base.")
            last_replaceable.set_cost(1000)
            last_replaceable.set_maintenance(3)
            last_replaceable.add_replaces(product_starbase)
            last_replaceable.add_replacement(product_star_fortress)
            last_built := last_replaceable
        when product_star_fortress then
            create last_replaceable.make(l("Star Fortress"), product_star_fortress)
            last_replaceable.set_description("A large military orbital platform. Has a +6 parsec scan range bonus and adds +20%% to both the offense and defense of all ships in combat around it. Replaces battlestations and star bases.")
            last_replaceable.set_cost(2500)
            last_replaceable.set_maintenance(4)
            last_replaceable.add_replaces(product_starbase)
            last_replaceable.add_replaces(product_battlestation)
            last_built := last_replaceable
        when product_pollution_processor then
            create last_cleaner.make(l("Pollution Processor"), product_pollution_processor)
            last_cleaner.set_description("Uses advanced chemicals to process factory waste. Only half of  the actual production of the planet used to calculate pollution.")
            last_cleaner.set_cost(80)
            last_cleaner.set_maintenance(1)
            last_cleaner.add_replacement(product_core_waste_dump)
            last_cleaner.set_cleansing_power(0.5)
            last_built := last_cleaner
        when product_atmosphere_renewer then
            create last_cleaner.make(l("Atmosphere Renewer"), product_atmosphere_renewer)
            last_cleaner.set_description("Eliminates many dangerous particles from the atmosphere of a planet. The amount of production is quartered before calculating pollution. Effects are cumulative with a pollution processor.")
            last_cleaner.set_cost(150)
            last_cleaner.set_maintenance(3)
            last_cleaner.add_replacement(product_core_waste_dump)
            last_cleaner.set_cleansing_power(0.25)
            last_built := last_cleaner
        when product_core_waste_dump then
            create last_cleaner.make(l("Core Waste Dump"), product_core_waste_dump)
            last_cleaner.set_description("Take man-made toxic/polluting agents and store them deep within the surface of a planet, far below surface water supplies. Planetary pollution is completely  eliminated.")
            last_cleaner.set_cost(200)
            last_cleaner.set_maintenance(8)
            last_cleaner.add_replaces(product_pollution_processor)
            last_cleaner.add_replaces(product_atmosphere_renewer)
            last_built := last_cleaner
        end
    ensure
        last_built.id = id
    end

    construction_from_design(design: like starship_type) is
    require
        design /= Void
    do
        create last_ship.make_starship(design)
        last_built := last_ship
    end

feature {NONE} -- Anchors

    starship_type: STARSHIP

end -- class CONSTRUCTION_BUILDER
