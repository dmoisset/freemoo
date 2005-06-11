class S_RACE
	
inherit
	RACE
	redefine set_attribute end
	SERVICE
	redefine subscription_message end
	
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
		-- Maravilloso
		Result := s.serialized_form
	end

end -- class S_RACE
