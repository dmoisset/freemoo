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
            c := p.colonies.item(p.colonies.lower)
            c.add_populator(task_farming)
            c.add_populator(task_industry)
            c.add_populator(task_industry)
            from
                tech := granted_technologies.get_new_iterator
            until tech.is_off loop
                p.known_constructions.add_by_id(tech.item)
                tech.next
            end
            create starship.make(p)
            starship.set_name("Scout")
            p.known_constructions.add_starship_design(starship)
            c.set_producing(p.known_constructions.last_added.id)
            players.next
        end
    end


feature {NONE} -- Auxiliar

    granted_technologies: ARRAY[INTEGER] is
    do
        Result := <<product_housing, product_trade_goods,
                    product_colony_ship, product_automated_factory,
                    product_research_laboratory,
                    product_astro_university, product_weather_controller,
                    product_hidroponic_farm, product_colony_base,
                    product_spaceport, product_stock_exchange,
                    product_gravity_generator, product_terraforming,
                    product_radiation_shield, product_flux_shield,
                    product_barrier_shield, product_cloning_center,
                    product_starbase, product_battlestation,
                    product_star_fortress, product_robo_mining_plant,
                    product_deep_core_mine, product_pollution_processor,
                    product_atmosphere_renewer, product_core_waste_dump,
                    product_biospheres, product_recyclotron,
                    product_soil_enrichment, product_gaia_transform,
                    product_capitol, product_marine_barracks,
                    product_armor_barracks, product_holosimulator,
                    product_pleasure_dome>>
    end

    starship: STARSHIP

    player_type: PLAYER

end -- class EVOLVER_PREWARP
