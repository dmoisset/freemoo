class C_CONSTRUCTION_ANDROID

inherit
    CONSTRUCTION_ANDROID
    redefine
        xeno_repository, populator
    end
    CLIENT

create
    make

feature {NONE}

    xeno_repository: C_XENO_REPOSITORY is
    do
        Result := server.xeno_repository
    end

    populator: C_POPULATION_UNIT

end -- class C_CONSTRUCTION_ANDROID
