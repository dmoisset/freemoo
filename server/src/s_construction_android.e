class S_CONSTRUCTION_ANDROID

inherit
    CONSTRUCTION_ANDROID
    redefine
        populator, colony_type
    end

create
    make

feature {NONE}

    populator: S_POPULATION_UNIT

    colony_type: S_COLONY

end -- class S_CONSTRUCTION_ANDROID
