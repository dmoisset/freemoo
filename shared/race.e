class RACE

inherit
    UNIQUE_ID

creation make

feature -- Access -- General

    name: STRING

    rulers: ARRAY [STRING]
        -- Usual ruler names (default choices from here)

    homeworld_name: STRING
        -- Default homeworld name

feature -- Access -- Bonuses

    population_growth: INTEGER
        -- percentage bonus, may be negative.

    farming_bonus: INTEGER
        -- number of extra half food units per population

    industry_bonus: INTEGER
        -- number of production units per population
    
    science_bonus: INTEGER
        -- number of RP per population
    
    money_bonus: INTEGER
        -- number of extra 0.5BC per population

    ship_defense_bonus, ship_attack_bonus: INTEGER
    
    ground_combat_bonus: INTEGER
    
    spying_bonus: INTEGER

feature -- Access -- government dependant    

    government: INTEGER
       -- one of the government_xxx constants

    government_feudal,
    government_dictatorship,
    government_democracy,
    government_unification: INTEGER is unique

    ship_cost_bonus: INTEGER is
        -- bonus for ship costs in 33% (1/3) units. Positive means cheaper
    do
        if government = government_feudal then Result := 1 end
    end

    morale_bonus: INTEGER is
        -- Percent morale bonus without marine barracks
    do
        if government = government_feudal or 
           government = government_dictatorship then
            Result := -20
        end
    end

    food_multiplier: INTEGER is
        -- Percentile food bonus
    do
        if government = government_unification then Result := +50 end
    end

    industry_multiplier: INTEGER is
        -- Percentile industry bonus
    do
        if government = government_unification then Result := +50 end
    end

    science_multiplier: INTEGER is
        -- Percentile science bonus
    do
        inspect government
        when government_feudal    then Result := -50
        when government_democracy then Result := +50
        else -- default is 0
        end
    end

    morale_multiplier: INTEGER is
        -- Percentile bonifier for morale
    do
        if government = government_unification then
            Result := -100
        end
    end

    defensive_spy_bonus: INTEGER is
        -- Bonus to defensive spy rolls
    do
        inspect government
        when government_dictatorship then Result := +10
        when government_democracy    then Result := -10
        when government_unification  then Result := +15
        else -- default is 0
        end
    end

    assimilation_time (other: RACE): INTEGER is
        -- Time taking for a player of this race to assimilate population from
        -- `other' race
    do
        if other.government = government_feudal then 
            -- feudals are assimilated for free
        else
            inspect government
            when government_feudal,
                 government_dictatorship then Result := 8
            when government_democracy    then Result := 4
            when government_unification  then Result := 20
            end
        end
    end

    can_annihilate: BOOLEAN is
        -- Can annihilate populators on conquered planets?
    do
        Result := government /= government_democracy
    end

feature -- Operations

    set_attribute(attr: STRING) is
-- General setter.  Can receive strings describing the attribute 
        -- to set.
    require
        attr /= Void
    local
        key, value: STRING
        eqpos: INTEGER
    do
        eqpos := attr.first_index_of('=')
        if eqpos /= 0 then
            key := attr.substring(1, eqpos - 1)
            value := attr.substring(eqpos, attr.count)
        else
            key := attr
            value := "True"
        end
        if key.is_equal("population_growth") and then value.is_integer then
            population_growth := value.to_integer
        elseif key.is_equal("farming_bonus") and then value.is_integer then
            farming_bonus := value.to_integer
        elseif key.is_equal("industry_bonus") and then value.is_integer then
            industry_bonus := value.to_integer
        elseif key.is_equal("science_bonus") and then value.is_integer then
            science_bonus := value.to_integer
        elseif key.is_equal("money_bonus") and then value.is_integer then
            money_bonus := value.to_integer
        elseif key.is_equal("ship_defense_bonus") and then value.is_integer then
            ship_defense_bonus := value.to_integer
        elseif key.is_equal("ship_attack_bonus") and then value.is_integer then
            ship_attack_bonus := value.to_integer
        elseif key.is_equal("ground_combat_bonus") and then value.is_integer then
            ground_combat_bonus := value.to_integer
        elseif key.is_equal("spying_bonus") and then value.is_integer then
            spying_bonus := value.to_integer
        elseif key.is_equal("government") and then value.is_equal("feudal") then
            government := government_feudal
        elseif key.is_equal("government") and then value.is_equal("dictatorship") then
            government := government_dictatorship
        elseif key.is_equal("government") and then value.is_equal("democracy") then
            government := government_democracy
        elseif key.is_equal("government") and then value.is_equal("unification") then
            government := government_unification
        elseif key.is_equal("homeworld_size") and then value.is_integer then
            homeworld_size := value.to_integer
        elseif key.is_equal("homeworld_gravity") and then value.is_integer then
            homeworld_gravity := value.to_integer
        elseif key.is_equal("homeworld_richness") and then value.is_integer then
            homeworld_richness := value.to_integer
        elseif key.is_equal("ancient_artifacts") and then value.is_boolean then
            ancient_artifacts := value.to_boolean
        elseif key.is_equal("aquatic") and then value.is_boolean then
            aquatic := value.to_boolean
        elseif key.is_equal("subterranean") and then value.is_boolean then
            subterranean := value.to_boolean
        elseif key.is_equal("cybernetic") and then value.is_boolean then
            cybernetic := value.to_boolean
        elseif key.is_equal("lithovore") and then value.is_boolean then
            lithovore := value.to_boolean
        elseif key.is_equal("repulsive") and then value.is_boolean then
            repulsive := value.to_boolean
        elseif key.is_equal("charismatic") and then value.is_boolean then
            charismatic := value.to_boolean
        elseif key.is_equal("uncreative") and then value.is_boolean then
            uncreative := value.to_boolean
        elseif key.is_equal("tolerant") and then value.is_boolean then
            tolerant := value.to_boolean
        elseif key.is_equal("fantastic_trader") and then value.is_boolean then
            fantastic_trader := value.to_boolean
        elseif key.is_equal("telepathic") and then value.is_boolean then
            telepathic := value.to_boolean
        elseif key.is_equal("lucky") and then value.is_boolean then
            lucky := value.to_boolean
        elseif key.is_equal("omniscient") and then value.is_boolean then
            omniscient := value.to_boolean
        elseif key.is_equal("stealthy") and then value.is_boolean then
            stealthy := value.to_boolean
        elseif key.is_equal("transdimensional") and then value.is_boolean then
            transdimensional := value.to_boolean
        else
            check invalid_option: false end
        end
    end

feature -- Access -- Special

    homeworld_size: INTEGER
        -- -2 for tiny, -1 for small, 0 for normal, +1 for large, +2 for huge.
        -- (easy to add to size constants from MAP_CONSTANTS)

    homeworld_gravity: INTEGER
        -- -1 for low, 0 for normal, +1 for high
        -- (easy to add to gravity constants from MAP_CONSTANTS)

    homeworld_richness: INTEGER
        -- -2 for UP, -1 for poor, 0 for normal, +1 for rich, +2 for UR
        -- (easy to add to richness constants from MAP_CONSTANTS)

    ancient_artifacts: BOOLEAN

    aquatic, subterranean, cybernetic, lithovore, repulsive,
    charismatic, uncreative, creative, tolerant, fantastic_trader,
    telepathic, lucky, omniscient, stealthy, transdimensional, 
    warlord: BOOLEAN

feature {NONE} -- Creation

    make is
    do
        make_unique_id
        government := government_dictatorship
        name := ""
    end

invariant
    government.in_range (government_feudal, government_unification)
    ship_cost_bonus <= 3 -- Otherwise ships would have negative cost    
    not (creative and uncreative)
    not (charismatic and repulsive)
    not (lithovore and cybernetic)
    homeworld_gravity.in_range(-1, 1)
    homeworld_richness.in_range(-2, 2)
    homeworld_size.in_range(-2, 2)
end -- class RACE
