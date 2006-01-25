class CONSTRUCTION_SOIL_ENRICHMENT

inherit
    BASIC_PRODUCTIVE_CONSTRUCTION
    rename
        make as construction_make
    redefine
        can_be_built_on
    end
    GETTEXT

create
    make

feature

    can_be_built_on(c: like colony_type): BOOLEAN is
    do
        Result := not c.constructions.has(id) and
                    c.location.climate > c.location.climate_barren
    end

feature {NONE} -- Creation

    make is
    do
        id := product_soil_enrichment
        name := l("Soil Enrichment")
        base_cost := 120
        farming_proportional := 1
        description := no_description
    end

end -- class CONSTRUCTION_SOIL_ENRICHMENT
