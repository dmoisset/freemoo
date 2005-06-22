deferred class MAP_GENERATOR

feature {NONE} -- Creation

    make (options: SERVER_OPTIONS) is
    require
        options /= Void
    deferred
    end

feature -- Operations

    generate (galaxy: GALAXY; players: PLAYER_LIST [PLAYER]) is
        -- Generate `galaxy' for a game with `players'
        -- Store homeworld for each player in `homeworlds'
    require
        galaxy /= Void
--        fresh_galaxy: galaxy.stars.count = 0
        players /= Void
    deferred
    ensure
        homeworlds /= Void
        homeworlds.count = players.count
    end

    add_omniscient_knowledge(galaxy: GALAXY; players: PLAYER_LIST[PLAYER]) is
    local
        pl: ITERATOR[PLAYER]
        st: ITERATOR[STAR]
    do
        from
            pl := players.get_new_iterator
        until
            pl.is_off
        loop
            if pl.item.race.omniscient then
                from
                    st := galaxy.get_new_iterator_on_stars
                until
                    st.is_off
                loop
                    pl.item.add_to_known_list(st.item)
                    st.next
                end
            end
            pl.next
        end
    end

feature -- Access

    homeworlds: ARRAY [PLANET]
        -- Homeworld of each player, indexed by color
    
end -- class MAP_GENERATOR
