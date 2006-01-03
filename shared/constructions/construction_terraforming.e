class CONSTRUCTION_TERRAFORMING

inherit
    CONSTRUCTION
    GETTEXT

create make

feature

    name: STRING is
    do
        Result := l("Terraforming")
    end

    can_be_built_on(c: like colony_type): BOOLEAN is
    do
        Result := terraforming_results.has(c.location.climate)
    end

    produce_proportional, produce_fixed, generate_money,
    clean_up_pollution, take_down(c: like colony_type) is
    do
    end

    maintenance(c: like colony_type): INTEGER is
    do
    end

    cost(c: like colony_type): INTEGER is
    do
        Result := (c.terraformed + 1) * 250
    end

    build(c: like colony_type) is
    do
        c.terraform_to(terraforming_results.at(c.location.climate))
    end

feature {NONE} -- Creation

    make is
    do
        id := product_terraforming
        description := "Makes a planet more hospitable. Barren becomes desert or tundra, deserts become arid, tundras become swamp, oceans, swamps and arid become terran. Each use on  a planet increases cost by 250 production."
    end

feature {NONE} -- Auxiliar

    terraforming_results: HASHED_DICTIONARY[INTEGER, INTEGER] is
    local
        c: MAP_CONSTANTS
    once
        create c
        create Result.make
        Result.add(c.climate_tundra, c.climate_barren)
        Result.add(c.climate_arid, c.climate_desert)
        Result.add(c.climate_swamp, c.climate_tundra)
        Result.add(c.climate_terran, c.climate_ocean)
        Result.add(c.climate_terran, c.climate_swamp)
        Result.add(c.climate_terran, c.climate_arid)
    end

end -- class CONSTRUCTION_TERRAFORMING
