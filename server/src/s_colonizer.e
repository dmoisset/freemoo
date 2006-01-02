class S_COLONIZER

inherit
    COLONIZER
    redefine
        planet_to_colonize, owner
    end

feature

    owner: S_PLAYER

    planet_to_colonize: S_PLANET

end -- class S_COLONIZER
