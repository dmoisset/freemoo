class S_RACE
	
inherit
	RACE
	redefine set_attribute end
	SERVICE
	redefine subscription_message end
    STORABLE
    rename
		hash_code as id
    redefine
		primary_keys
    end
	
creation make
	
feature
	
	set_attribute(attr: STRING) is
	do
		Precursor(attr)
		update_clients
	end
	
feature
    
	update_clients is
    do
        -- Check to avoid updates on initialization
        if registry /= Void then
            send_message ("race" + id.to_string, subscription_message ("race" + id.to_string))
        end
    end
	
    subscription_message (service_id: STRING): STRING is
    require
		service_id.is_equal("race" + id.to_string)
	local
        s: SERIALIZER2
    do
        !!s.make
		s.add_tuple(<<name, homeworld_name,
		  population_growth, farming_bonus, industry_bonus,
		  science_bonus, money_bonus, ship_defense_bonus,
		  ship_attack_bonus, ground_combat_bonus, spying_bonus,
		  government-government_feudal, large_homeworld, homeworld_gravity,
		  homeworld_richness, ancient_artifacts, aquatic,
		  subterranean, cybernetic, lithovore, repulsive, charismatic,
		  uncreative, creative, tolerant, fantastic_trader,
		  telepathic, lucky, omniscient, stealthy, transdimensional>>)
		Result := s.serialized_form
	end
	
	    
feature {STORAGE} -- Saving
	
    get_class: STRING is "RACE"
	
    fields: ITERATOR[TUPLE[STRING, ANY]] is
    local
		a: ARRAY[TUPLE[STRING, ANY]]
    do
		create a.make(1, 0)
		a.add_last(["name", name])
		a.add_last(["homeworld_name", homeworld_name])
		a.add_last(["population_growth", population_growth])
		a.add_last(["farming_bonus", farming_bonus])
		a.add_last(["industry_bonus", industry_bonus])
		a.add_last(["science_bonus", science_bonus])
		a.add_last(["money_bonus", money_bonus])
		a.add_last(["ship_defense_bonus", ship_defense_bonus])
		a.add_last(["ship_attack_bonus", ship_attack_bonus])
		a.add_last(["ground_combat_bonus", ground_combat_bonus])
		a.add_last(["spying_bonus", spying_bonus])
		a.add_last(["government", government - government_feudal])
		a.add_last(["large_homeworld", large_homeworld])
		a.add_last(["homeworld_gravity", homeworld_gravity])
		a.add_last(["homeworld_richness", homeworld_richness])
		a.add_last(["ancient_artifacts", ancient_artifacts])
		a.add_last(["aquatic", aquatic])
		a.add_last(["subterranean", subterranean])
		a.add_last(["cybernetic", cybernetic])
		a.add_last(["lithovore", lithovore])
		a.add_last(["repulsive", repulsive])
		a.add_last(["charismatic", charismatic])
		a.add_last(["uncreative", uncreative])
		a.add_last(["creative", creative])
		a.add_last(["tolerant", tolerant])
		a.add_last(["fantastic_trader", fantastic_trader])
		a.add_last(["telepathic", telepathic])
		a.add_last(["lucky", lucky])
		a.add_last(["omniscient", omniscient])
		a.add_last(["stealthy", stealthy])
		a.add_last(["transdimensional", transdimensional])
		Result := a.get_new_iterator
	end
    
    primary_keys: ITERATOR[TUPLE[STRING, ANY]] is
    do
		Result := (<<["id", id] >>).get_new_iterator
    end
	
feature {STORAGE} -- Retrieving
	
    set_primary_keys (elems: ITERATOR [TUPLE [STRING, ANY]]) is
    local
		i: reference INTEGER
    do
		from
		until elems.is_off loop
			if elems.item.first.is_equal("id") then
				i ?= elems.item.second
				id := i
			end
			elems.next
		end
    end
    
feature {STORAGE} -- Retrieving
    
    make_from_storage (elems: ITERATOR [TUPLE [STRING, ANY]]) is
    local
		i: reference INTEGER
		b: reference BOOLEAN
	do
		from
		until elems.is_off loop
			if elems.item.first.is_equal("name") then
				name ?= elems.item.second
			elseif elems.item.first.is_equal("homeworld_name") then
				homeworld_name ?= elems.item.second
			elseif elems.item.first.is_equal("population_growth") then
				i ?= elems.item.second
				population_growth := i
			elseif elems.item.first.is_equal("farming_bonus") then
				i ?= elems.item.second
				farming_bonus := i
			elseif elems.item.first.is_equal("industry_bonus") then
				i ?= elems.item.second
				industry_bonus := i
			elseif elems.item.first.is_equal("science_bonus") then
				i ?= elems.item.second
				science_bonus := i
			elseif elems.item.first.is_equal("money_bonus") then
				i ?= elems.item.second
				money_bonus := i
			elseif elems.item.first.is_equal("ship_defense_bonus") then
				i ?= elems.item.second
				ship_defense_bonus := i
			elseif elems.item.first.is_equal("ship_attack_bonus") then
				i ?= elems.item.second
				ship_attack_bonus := i
			elseif elems.item.first.is_equal("ground_combat_bonus") then
				i ?= elems.item.second
				ground_combat_bonus := i
			elseif elems.item.first.is_equal("spying_bonus") then
				i ?= elems.item.second
				spying_bonus := i
			elseif elems.item.first.is_equal("government") then
				i ?= elems.item.second
				government := i + government_feudal
			elseif elems.item.first.is_equal("large_homeworld") then
				b ?= elems.item.second
				large_homeworld := b
			elseif elems.item.first.is_equal("homeworld_gravity") then
				i ?= elems.item.second
				homeworld_gravity := i
			elseif elems.item.first.is_equal("ancient_artifacts") then
				b ?= elems.item.second
				ancient_artifacts := b
			elseif elems.item.first.is_equal("aquatic") then
				b ?= elems.item.second
				aquatic := b
			elseif elems.item.first.is_equal("subterranean") then
				b ?= elems.item.second
				subterranean := b
			elseif elems.item.first.is_equal("cybernetic") then
				b ?= elems.item.second
				cybernetic := b
			elseif elems.item.first.is_equal("lithovore") then
				b ?= elems.item.second
				lithovore := b
			elseif elems.item.first.is_equal("repulsive") then
				b ?= elems.item.second
				repulsive := b
			elseif elems.item.first.is_equal("charismatic") then
				b ?= elems.item.second
				charismatic := b
			elseif elems.item.first.is_equal("uncreative") then
				b ?= elems.item.second
				uncreative := b
			elseif elems.item.first.is_equal("creative") then
				b ?= elems.item.second
				creative := b
			elseif elems.item.first.is_equal("tolerant") then
				b ?= elems.item.second
				tolerant := b
			elseif elems.item.first.is_equal("fantastic_trader") then
				b ?= elems.item.second
				fantastic_trader := b
			elseif elems.item.first.is_equal("telepathic") then
				b ?= elems.item.second
				telepathic := b
			elseif elems.item.first.is_equal("lucky") then
				b ?= elems.item.second
				telepathic := b
			elseif elems.item.first.is_equal("omniscient") then
				b ?= elems.item.second
				omniscient := b
			elseif elems.item.first.is_equal("stealthy") then
				b ?= elems.item.second
				stealthy := b
			elseif elems.item.first.is_equal("transdimensional") then
				b ?= elems.item.second
				transdimensional := b
			end
		elems.next
		end
    end
	

end -- class S_RACE
