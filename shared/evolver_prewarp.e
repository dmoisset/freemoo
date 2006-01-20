class EVOLVER_PREWARP

inherit
    EVOLVER
    PRODUCTION_CONSTANTS

creation make

feature {NONE} -- Creation

    make(o: SERVER_OPTIONS) is
    do
    end

feature -- Operations

    evolve (players: ITERATOR [like player_type]) is
        -- Configure `players' to initial state.
    local
        p: like player_type
        c: COLONY
        tech: ITERATOR[INTEGER]
    do
        from until players.is_off loop
            p := players.item
            -- Initial technology
            from
                tech := granted_technologies.get_new_iterator
            until tech.is_off loop
                p.known_constructions.add_by_id(tech.item)
                tech.next
            end
            -- Create colony and populators (4 farmers, 2 workers, 2 scientist)
            c := p.colonies.item(p.colonies.lower)
            c.add_populator(task_farming)
            c.add_populator(task_farming)
            c.add_populator(task_farming)
            c.add_populator(task_farming)
            c.add_populator(task_industry)
            -- There is already a worker, by default
            c.add_populator(task_science)
            c.add_populator(task_science);
            -- Basic buildings
            (p.known_constructions @ product_capitol).build (c);
            (p.known_constructions @ product_marine_barracks).build (c);
            (p.known_constructions @ product_star_base).build (c);
            -- Basic starship design
            create starship.make(p)
            starship.set_name("Scout")
            p.known_constructions.add_starship_design(starship)
            -- Initially building scout
            c.set_producing(p.known_constructions.last_added.id)
            players.next
        end
    end


feature {NONE} -- Auxiliar

    granted_technologies: ARRAY[INTEGER] is
    do
        Result := <<product_colony_ship, product_housing,
                    product_automated_factory, product_robo_mining_plant,
                    product_deep_core_mine, product_astro_university,
                    product_research_laboratory, product_supercomputer,
                    product_autolab, product_galactic_cybernet,
                    product_hidroponic_farm, product_subterranean_farms,
                    product_weather_controller, product_colony_base,
                    product_spaceport, product_stock_exchange,
                    product_gravity_generator, product_terraforming,
                    product_radiation_shield, product_flux_shield,
                    product_barrier_shield, product_cloning_center,
                    product_biospheres, product_star_base,
                    product_battlestation, product_star_fortress,
                    product_pollution_processor, product_atmosphere_renewer,
                    product_core_waste_dump, product_recyclotron,
                    product_soil_enrichment, product_gaia_transform,
                    product_marine_barracks, product_armor_barracks,
                    product_capitol, product_holosimulator,
                    product_pleasure_dome, product_android_farmer,
                    product_android_worker, product_android_scientist,
                    product_artificial_planet>>
    end

    starship: STARSHIP

    player_type: PLAYER

end -- class EVOLVER_PREWARP
