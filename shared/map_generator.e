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
        players /= Void
    deferred
    ensure
        homeworlds /= Void
        homeworlds.count = players.count
    end

feature -- Access

    homeworlds: ARRAY [PLANET]
        -- Homeworld of each player, indexed by color_id

end -- class MAP_GENERATOR
