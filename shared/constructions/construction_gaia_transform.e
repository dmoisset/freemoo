class CONSTRUCTION_GAIA_TRANSFORM

inherit
    CONSTRUCTION
    rename
        make as construction_make
    redefine
        can_be_built_on, cost, build
    end
    GETTEXT

create
    make

feature

    can_be_built_on(c: like colony_type): BOOLEAN is
    do
        Result := c.location.climate = c.location.climate_terran
    end

    cost(c: like colony_type): INTEGER is
    do
        Result := 500
    end

    build(c: like colony_type) is
    do
        c.terraform_to(c.location.climate_gaia)
    end

feature {NONE} -- Creation

    make is
    do
        id := product_gaia_transform
        name := l("Gaia Transformation")
        description := no_description
    end

end -- class CONSTRUCTION_GAIA_TRANSFORM
