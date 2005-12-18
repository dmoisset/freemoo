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

    evolve (players: ITERATOR [PLAYER]) is
        -- Configure `players' to initial state.
    local
        p: PLAYER
        c: COLONY
        tech: ITERATOR[INTEGER]
    do
        from until players.is_off loop
            p := players.item
            c := p.colonies.item(p.colonies.lower)
            c.set_producing (product_starship)
            c.add_populator(task_farming)
            c.add_populator(task_industry)
            c.add_populator(task_industry)
            from
                tech := granted_technologies.get_new_iterator
            until tech.is_off loop
                p.known_constructions.add_by_id(tech.item)
                tech.next
            end
            players.next
        end
    end


feature {NONE} -- Auxiliar

    granted_technologies: ARRAY[INTEGER] is
    do
        Result := <<product_housing, product_trade_goods, product_colony_ship,
                    product_automated_factory>>
    end

end -- class EVOLVER_PREWARP
