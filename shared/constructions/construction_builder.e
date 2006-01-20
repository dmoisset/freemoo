class CONSTRUCTION_BUILDER
--
-- Can create new constructions just with their id.  This class
-- concentrates all the special cases for construction creation.
--

inherit
    PRODUCTION_CONSTANTS
    GETTEXT
    PKG_USER

feature -- Access

    last_built: CONSTRUCTION

feature -- Operations

-- why this isn't a query?

    construction_by_id (id: INTEGER) is
    require
        id.in_range(product_min, product_max)
    do
        if cache.valid_index (id) and then cache @ id /= Void then
            last_built := cache @ id
        else
            inspect
                id
            when product_colony_ship then
                create last_ship.make_colony_ship
                last_built := last_ship
            when product_housing then
                create last_ongoing.make(l("Housing"), product_housing)
                last_ongoing.set_description(l("Housing converts the production of a colony into population growth."))
                last_built := last_ongoing
            when product_trade_goods then
                create last_ongoing.make(l("Trade Goods"), product_trade_goods)
                last_ongoing.set_description(l("Trade Goods converts the production of a colony into BCs for the imperial treasury."))
                last_built := last_ongoing
            when product_colony_base then
                create {CONSTRUCTION_COLONY_BASE}last_built.make
            when product_gravity_generator then
                create {CONSTRUCTION_GRAVITY_GENERATOR}last_built.make
            when product_terraforming then
                create {CONSTRUCTION_TERRAFORMING}last_built.make
            when product_recyclotron then
                create {CONSTRUCTION_RECYCLOTRON}last_built.make
            when product_soil_enrichment then
                create {CONSTRUCTION_SOIL_ENRICHMENT}last_built.make
            when product_gaia_transform then
                create {CONSTRUCTION_GAIA_TRANSFORM}last_built.make
            when product_capitol then
                create {CONSTRUCTION_CAPITOL}last_built.make
            when product_artificial_planet then
                create {CONSTRUCTION_ARTIFICIAL_PLANET}last_built.make
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
            when product_biospheres then
                create last_persistent.make(l("Biospheres"), product_biospheres)
                last_persistent.set_description("Enables a colony to better control environmental conditions, allowing  colonization of the more intolerable areas of the planet. Maximum planetary population is increased by +2 million.")
                last_persistent.set_cost(60)
                last_persistent.set_maintenance(1)
                last_built := last_persistent
            when product_star_base then
                create last_replaceable.make(l("Star Base"), product_star_base)
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
                last_replaceable.add_replaces(product_star_base)
                last_replaceable.add_replacement(product_star_fortress)
                last_built := last_replaceable
            when product_star_fortress then
                create last_replaceable.make(l("Star Fortress"), product_star_fortress)
                last_replaceable.set_description("A large military orbital platform. Has a +6 parsec scan range bonus and adds +20%% to both the offense and defense of all ships in combat around it. Replaces battlestations and star bases.")
                last_replaceable.set_cost(2500)
                last_replaceable.set_maintenance(4)
                last_replaceable.add_replaces(product_star_base)
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
            when product_holosimulator then
                create last_moralizer.make(l("Holosimulator"), product_holosimulator)
                last_moralizer.set_description(l("Capable of creating realistic 3-D images from holographic projections. Increases a planet's morale by +20%%."))
                last_moralizer.set_cost(120)
                last_moralizer.set_maintenance(1)
                last_moralizer.set_morale(20)
                last_built := last_moralizer
            when product_pleasure_dome then
                create last_moralizer.make(l("Pleasure Dome"), product_pleasure_dome)
                last_moralizer.set_description(l("The ultimate in virtual holographic entertainment, creating completely immersive entertainment environments. It increases morale by +30%% and is  cumulative with holo simulator."))
                last_moralizer.set_cost(250)
                last_moralizer.set_maintenance(3)
                last_moralizer.set_morale(30)
                last_built := last_moralizer
            when product_marine_barracks then
                create last_barracks.make(l("Marine Barracks"), product_marine_barracks)
                last_barracks.set_description(l("Lets the colony train troops for ground invasion protection. Begins with 4 marine units, then trains 1 unit every 5 turns, up to the planet's maximum population. Eliminates morale penalties for dictatorships and feudal governments."))
                last_barracks.set_cost(60)
                last_barracks.set_maintenance(1)
                last_built := last_barracks
            when product_armor_barracks then
                create last_barracks.make(l("Armor Barracks"), product_armor_barracks)
                last_barracks.set_description(l("Creates tank battalions. It has 2 units when built, and adds 1 unit every 10 turns, up to half the planet's population. Eliminates the morale penalty for dictatorships and feudal governments."))
                last_barracks.set_cost(150)
                last_barracks.set_maintenance(2)
                last_built := last_barracks
            when product_android_farmer then
                create last_android.make(l("Android Farmer"), product_android_farmer)
                last_android.set_description(l("Mechanical workers with a +3 food production bonus. Require 1 production unit per turn instead of food. They are unaffected by morale, receive no racial bonuses, and generate no income."))
                last_android.set_task(task_farming)
                last_built := last_android
            when product_android_worker then
                create last_android.make(l("Android Worker"), product_android_worker)
                last_android.set_description(l("Mechanical workers with a +3 production bonus. Require 1 production unit per turn instead of food. They are unaffected by morale, receive no racial bonuses, and cannot generate income."))
                last_android.set_task(task_industry)
                last_built := last_android
            when product_android_scientist then
                create last_android.make(l("Android Scientist"), product_android_scientist)
                last_android.set_description(l("Mechanical workers that generate 3 research points per turn. Require 1 production unit per turn instead of food. They are unaffected by morale, receive no racial bonuses, and cannot generate income."))
                last_android.set_task(task_science)
                last_built := last_android
            end
            cache.force (last_built, last_built.id)
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

feature {NONE} -- Internal

    last_ongoing: ONGOING_CONSTRUCTION

    last_shield: CONSTRUCTION_SHIELD

    last_ship: SHIP_CONSTRUCTION

    last_persistent: PERSISTENT_CONSTRUCTION

    last_replaceable: REPLACEABLE_CONSTRUCTION

    last_cleaner: CONSTRUCTION_DEPOLLUTER

    last_moralizer: CONSTRUCTION_MORALIZER

    last_barracks: CONSTRUCTION_BARRACKS

    last_android: CONSTRUCTION_ANDROID

    cache: ARRAY [CONSTRUCTION] is
    once
        create Result.make (1, 0)
        load_productive_constructions 
    end

    load_productive_constructions is
    local
        c: BASIC_PRODUCTIVE_CONSTRUCTION
        f: COMMENTED_TEXT_FILE
        w: ARRAY [STRING]
        id: INTEGER
    do
        pkg_system.open_file ("colony/productive_buildings")
        create f.make (pkg_system.last_file_open)
        from
            f.read_nonempty_line
        until f.last_line.first = '*' loop
            w := f.last_line.split
            id := w.item (1).to_integer
            create c.make (construction_info.item(id).first, id+product_min)
            c.set_description (construction_info.item(id).second)
            c.set_cost (w.item (2).to_integer)
            c.set_maintenance (w.item (3).to_integer)
            c.set_farming (w.item (7).to_integer, w.item (4).to_integer)
            c.set_industry (w.item (8).to_integer, w.item (5).to_integer)
            c.set_science (w.item (9).to_integer, w.item (6).to_integer)
            c.set_money (w.item (10).to_integer)
            cache.force (c, id+product_min)
            f.read_nonempty_line
        end
    end

    construction_info: ARRAY [TUPLE [STRING, STRING]] is
        -- name/description, by id-product_min
    local
        f: COMMENTED_TEXT_FILE
        id, p, q: INTEGER
        name, description: STRING
        
    once
        create Result.make (1, 0)
        pkg_system.open_file ("colony/buildings")
        create f.make (pkg_system.last_file_open)
        from
            f.read_nonempty_line
        until f.last_line.first = '*' loop
            p := f.last_line.index_of ('|', 1)
            id := f.last_line.substring (1, p-1).to_integer
            q := f.last_line.index_of ('|', p+1)
            name := f.last_line.substring (p+1, q-1)
            p := f.last_line.count
            description := f.last_line.substring (q+1, p)
        
            Result.force ([name, description], id)
            f.read_nonempty_line
        end
        
    end


feature {NONE} -- Anchors

    starship_type: STARSHIP

end -- class CONSTRUCTION_BUILDER
