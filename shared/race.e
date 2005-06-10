class RACE

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

feature -- Access -- Special

    large_homeworld: BOOLEAN

    homeworld_gravity: INTEGER
        -- -1 for low, 0 for normal, +1 for high
        -- (easy to add to gravity constants from MAP_CONSTANTS)

    homeworld_richness: INTEGER
        -- -1 for poor, 0 for normal, +1 for rich
        -- (easy to add to richness constants from MAP_CONSTANTS)

    ancient_artifacts: BOOLEAN

    aquatic, subterranean, cybernetic, lithovore, repulsive,
    charismatic, uncreative, creative, tolerant, fantastic_trader,
    telepathic, lucky, omniscient, stealthy, transdimensional: BOOLEAN
    
invariant
    government.in_range (government_feudal, government_unification)
    ship_cost_bonus <= 3 -- Otherwise ships would have negative cost    
    not (creative and uncreative)
    not (charismatic and repulsive)
    
end -- class RACE