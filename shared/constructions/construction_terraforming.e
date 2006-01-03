class CONSTRUCTION_TERRAFORMING

inherit
    CONSTRUCTION
        rename
            make as construction_make
        redefine
            can_be_built_on, cost, build
        end
    GETTEXT
    RANDOM_ACCESS

create make

feature

    can_be_built_on(c: like colony_type): BOOLEAN is
    do
        Result := terraforming_results.has(c.location.climate)
    end

    cost(c: like colony_type): INTEGER is
    do
        Result := (c.terraformed + 1) * 250
    end

    build(c: like colony_type) is
    local
        outcomes: HASHED_SET[INTEGER]
    do
        outcomes := terraforming_results.at(c.location.climate)
        rand.next
        c.terraform_to(outcomes.item(rand.last_integer(outcomes.count)))
    end

feature {NONE} -- Creation

    make is
    do
        name := l("Terraforming")
        id := product_terraforming
        description := l("Makes a planet more hospitable. Barren becomes desert or tundra, deserts become arid, tundras become swamp, oceans, swamps and arid become terran. Each use on  a planet increases cost by 250 production.")
    end

feature {NONE} -- Auxiliar

    terraforming_results: HASHED_DICTIONARY[HASHED_SET[INTEGER], INTEGER] is
    local
        c: MAP_CONSTANTS
    once
        create c
        create Result.make
        Result.add(create {HASHED_SET[INTEGER]}.make, c.climate_barren)
        Result.at(c.climate_barren).add(c.climate_tundra)
        Result.at(c.climate_barren).add(c.climate_desert)
        Result.add(create {HASHED_SET[INTEGER]}.make, c.climate_desert)
        Result.at(c.climate_desert).add(c.climate_arid)
        Result.add(create {HASHED_SET[INTEGER]}.make, c.climate_tundra)
        Result.at(c.climate_tundra).add(c.climate_swamp)
        Result.add(create {HASHED_SET[INTEGER]}.make, c.climate_ocean)
        Result.at(c.climate_ocean).add(c.climate_terran)
        Result.add(create {HASHED_SET[INTEGER]}.make, c.climate_swamp)
        Result.at(c.climate_swamp).add(c.climate_terran)
        Result.add(create {HASHED_SET[INTEGER]}.make, c.climate_arid)
        Result.at(c.climate_arid).add(c.climate_terran)
    end

end -- class CONSTRUCTION_TERRAFORMING
