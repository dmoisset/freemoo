class C_CONSTRUCTION_REPO

inherit
    CONSTRUCTION_REPO
    redefine
        builder
    end

create
    make

feature

    builder: C_CONSTRUCTION_BUILDER

end -- class C_CONSTRUCTION_REPO
