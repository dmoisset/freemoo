class S_EVOLVER_PREWARP

inherit
    EVOLVER_PREWARP
    redefine
        starship, player_type
    end

creation
    make

feature {NONE} -- Redefined features

    starship: S_STARSHIP

    player_type: S_PLAYER

end -- class S_EVOLVER_PREWARP
