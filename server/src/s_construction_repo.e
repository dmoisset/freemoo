class S_CONSTRUCTION_REPO

inherit
    CONSTRUCTION_REPO
    redefine builder, starship_type end

creation
    make

feature {NONE} -- Redefined features

    builder: S_CONSTRUCTION_BUILDER

    starship_type: S_STARSHIP

end -- class S_CONSTRUCTION_REPO
