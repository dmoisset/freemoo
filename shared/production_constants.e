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
    product_weather_controller, product_spy,
    product_colony_base: INTEGER is unique
        -- Possible production_items

    product_min: INTEGER is
        -- Minimum valid for `producing'
    do Result := product_none end

    product_max: INTEGER is
        -- Minimum valid for `producing'
    do Result := product_colony_base end

    task_farming, task_industry, task_science: INTEGER is unique
        -- Possible tasks for population_units

end -- PRODUCTION_CONSTANTS
