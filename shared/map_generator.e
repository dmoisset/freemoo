deferred class MAP_GENERATOR

feature {NONE} -- Creation

    make (options: SERVER_OPTIONS) is
    require
        options /= Void
    deferred
    end
-- Supongo que aca guardaras options en algun lado, o sacaras las que
-- te hagan falta.

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
-- Acá irás generando y metiendo lo que haga falta. Probablemente
-- necesites sacar la cantidad de players para distribuir homeworlds
-- y en un futuro datos raciales para ponerle el tipo a los planetas
--
-- Para meter cosas en la galaxia podés hacer un método add_star
-- en GALAXY (como el add_ship que hay ahora). 

feature -- Access

    homeworlds: ARRAY [PLANET]
        -- Homeworld of each player, indexed by color_id

end -- class MAP_GENERATOR
