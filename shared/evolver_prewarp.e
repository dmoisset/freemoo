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
            -- Initial technology and money
            from
                tech := granted_constructions.get_new_iterator
            until tech.is_off loop
                p.known_constructions.add_by_id(tech.item)
                tech.next
            end
            p.update_money (50)
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
            --create starship.make(p)
            --starship.set_name("Scout")
            --p.known_constructions.add_starship_design(starship)
            -- Initially trading goods
            c.set_producing(product_trade_goods)
            players.next
        end
    end


feature {NONE} -- Auxiliar

    granted_constructions: ARRAY[INTEGER] is
    do
        Result := <<product_housing, product_colony_base,
                    product_star_base, product_marine_barracks,
                    product_capitol>> -- Still missing spies!
    end

    starship: STARSHIP

    player_type: PLAYER

end -- class EVOLVER_PREWARP
