class PRODUCTION_CONSTANTS
--
-- Constants related to construction and production on colonies
-- 

feature -- Constants

    product_none, product_starship, product_colony_ship,
    product_housing, product_trade_goods,
    product_automated_factory, product_robo_mining_plant,
    product_deep_core_mine, product_astro_university,
    product_research_laboratory, product_supercomputer,
    product_autolab, product_galactic_cybernet,
    product_hidroponic_farm, product_subterranean_farms,
    product_weather_controller, product_spy, product_colony_base,
    product_spaceport, product_stock_exchange,
    product_gravity_generator, product_terraforming, product_radiation_shield,
    product_flux_shield, product_barrier_shield, product_cloning_center,
    product_biospheres, product_starbase, product_battlestation,
    product_star_fortress, product_pollution_processor,
    product_atmosphere_renewer, product_core_waste_dump,
    product_recyclotron, product_soil_enrichment, product_gaia_transform,
    product_marine_barracks, product_armor_barracks, product_capitol,
    product_holosimulator, product_pleasure_dome, product_android_farmer,
    product_android_worker, product_android_scientist: INTEGER is unique
        -- Possible production_items

    product_min: INTEGER is
        -- Minimum valid for `producing'
    do Result := product_none end

    product_max: INTEGER is
        -- Maximum valid for `producing'
    do Result := product_android_scientist end

    task_none, task_farming, task_industry, task_science: INTEGER is unique
        -- Possible tasks for population_units

end -- PRODUCTION_CONSTANTS
