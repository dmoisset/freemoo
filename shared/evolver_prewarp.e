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
            c.set_producing(p.known_constructions.last_ship.id)
            players.next
        end
    end


feature {NONE} -- Auxiliar

    granted_technologies: ARRAY[INTEGER] is
    do
        Result := <<product_housing, product_trade_goods, product_colony_ship,
                    product_automated_factory, product_research_laboratory,
                    product_astro_university, product_weather_controller>>
    end

    starship: STARSHIP

    player_type: PLAYER

end -- class EVOLVER_PREWARP
