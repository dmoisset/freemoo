class CONSTRUCTION_CAPITOL

inherit
    PERSISTENT_CONSTRUCTION
    rename
        make as construction_make
    redefine
        can_be_built_on, build, take_down
    end
    GETTEXT

create
    make

feature

    can_be_built_on(c: like colony_type): BOOLEAN is
    do
        Result := not c.owner.has_capitol
    end

    build(c: like colony_type) is
    do
        if not c.owner.has_capitol then
            Precursor(c)
            c.owner.capitol_built
        end
    end

    take_down(c: like colony_type) is
    do
        c.owner.capitol_destroyed
        Precursor(c)
    end

feature {NONE} -- Creation

    make is
    do
        id := product_capitol
        name := l("Capitol")
        base_cost := 500
        description := no_description
    end

end -- class CONSTRUCTION_CAPITOL
