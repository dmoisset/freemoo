class TECHNOLOGY_BUILDER
--
-- This class manages the creation of technologies.
-- To know how technologies are grouped into fields and categories, their costs,
-- names and descriptions, look at TECHNOLOGY_TREE.
--

inherit
    TECHNOLOGY_CONSTANTS
    PRODUCTION_CONSTANTS

feature

    last_tech: TECHNOLOGY

    by_id(id: INTEGER) is
        -- Builds a technology with the given id.  If we don't know how to
        -- build this technology, we return a dummy technology that doesn't
        -- do anything when researched (for not-yet-implemented techs)
    local
        construction: TECHNOLOGY_CONSTRUCTION
    do
        if construction_map.has(id) then
            create construction.make (id, construction_map.at(id))
            last_tech := construction
        else
            -- Other techs here...
            create {TECHNOLOGY_DUMMY}last_tech.make (id)
        end
    end

    construction_map: HASHED_DICTIONARY[INTEGER, INTEGER] is
    once
        create Result.make
        Result.put(product_colony_base, tech_colony_base)
        Result.put(product_star_base, tech_star_base)
        Result.put(product_marine_barracks, tech_marine_barracks)
        Result.put(product_automated_factory, tech_automated_factories)
--        Result.put(product_missile_base, tech_missile_base)
        Result.put(product_spaceport, tech_space_port)
        Result.put(product_armor_barracks, tech_armor_barracks)
--        Result.put(product_fighter_garrison, tech_fighter_garrison)
        Result.put(product_robo_mining_plant, tech_robo_miner_plant)
        Result.put(product_battlestation, tech_battle_station)
--        Result.put(product_ground_batteries, tech_ground_batteries)
        Result.put(product_recyclotron, tech_recyclotron)
        Result.put(product_artificial_planet, tech_artificial_planet)
--        Result.put(product_robotic_factory, tech_robotic_factory)
        Result.put(product_deep_core_mine, tech_deep_core_mine)
        Result.put(product_core_waste_dump, tech_core_waste_dump)
        Result.put(product_star_fortress, tech_star_fortress)
        Result.put(product_colony_ship, tech_colony_ship)
--        Result.put(product_freighters, tech_freighters)
--        Result.put(product_outpost_ship, tech_outpost_ship)
--        Result.put(product_transport_ship, tech_transport_ship)
        Result.put(product_atmosphere_renewer, tech_atmosphere_renewer)
--        Result.put(product_space_academy, tech_space_academy)
--        Result.put(product_alien_cont_center, tech_alien_cont_center)
        Result.put(product_stock_exchange, tech_stock_exchange)
        Result.put(product_astro_university, tech_astro_university)
        Result.put(product_research_laboratory, tech_research_lab)
        Result.put(product_supercomputer, tech_planetary_supercomputer)
        Result.put(product_holosimulator, tech_holo_simulator)
        Result.put(product_autolab, tech_autolab)
        Result.put(product_android_farmer, tech_android_farmers)
        Result.put(product_android_worker, tech_android_workers)
        Result.put(product_android_scientist, tech_android_scientist)
        Result.put(product_galactic_cybernet, tech_galactic_cybernet)
        Result.put(product_pleasure_dome, tech_pleasure_dome)
        Result.put(product_hidroponic_farm, tech_hydroponic_farm)
        Result.put(product_biospheres, tech_biospheres)
        Result.put(product_cloning_center, tech_cloning_center)
        Result.put(product_soil_enrichment, tech_soil_enrichment)
        Result.put(product_terraforming, tech_terraforming)
        Result.put(product_subterranean_farms, tech_subterranean_farms)
        Result.put(product_weather_controller, tech_weather_controller)
        Result.put(product_gaia_transform, tech_gaia_transformation)
        Result.put(product_gravity_generator, tech_gravity_generator)
        Result.put(product_radiation_shield, tech_radiation_shield)
        Result.put(product_flux_shield, tech_flux_shield)
        Result.put(product_barrier_shield, tech_barrier_shield)
    end

end -- class TECHNOLOGY_BUILDER
