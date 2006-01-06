class S_CONSTRUCTION_ANDROID

inherit
    CONSTRUCTION_ANDROID
    redefine
        xeno_repository, populator, colony_type
    end
    SERVER_ACCESS

create
    make

feature {NONE}

    populator: S_POPULATION_UNIT

    colony_type: S_COLONY

    xeno_repository: S_XENO_REPOSITORY is
    do
        --check server.game.xeno_repository /= Void end
        Result := server.game.xeno_repository
    end

end -- class S_CONSTRUCTION_ANDROID
