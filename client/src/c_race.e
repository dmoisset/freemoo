class C_RACE
	
inherit 
	RACE
	SUBSCRIBER
	
feature
	
	on_message (msg: STRING; provider: SERVICE_PROVIDER; service: STRING) is
        -- Action when `msg' arrives from `provider''s `service'
    local
        s: UNSERIALIZER
    do
		!!s.start (msg)
		s.get_string
		name := s.last_string
		s.get_string
		homeworld_name := s.last_string
		s.get_integer
		population_growth := s.last_integer
		s.get_integer
		farming_bonus := s.last_integer
		s.get_integer
		industry_bonus := s.last_integer
		s.get_integer
		science_bonus := s.last_integer
		s.get_integer
		money_bonus := s.last_integer
		s.get_integer 
		ship_defense_bonus := s.last_integer
		s.get_integer 
		ship_attack_bonus := s.last_integer
		s.get_integer 
		ground_combat_bonus := s.last_integer
		s.get_integer 
		spying_bonus := s.last_integer
		s.get_integer 
		government := s.last_integer + government_feudal
		s.get_integer
		homeworld_size := s.last_integer
		s.get_integer
		homeworld_gravity := s.last_integer
		s.get_integer
		homeworld_richness := s.last_integer
		s.get_boolean
		ancient_artifacts := s.last_boolean
		s.get_boolean
		aquatic := s.last_boolean
		s.get_boolean
		subterranean := s.last_boolean
		s.get_boolean
		cybernetic := s.last_boolean
		s.get_boolean
		lithovore := s.last_boolean
		s.get_boolean
		repulsive := s.last_boolean
		s.get_boolean
		charismatic := s.last_boolean
		s.get_boolean
		uncreative := s.last_boolean
		s.get_boolean
		creative := s.last_boolean
		s.get_boolean
		tolerant := s.last_boolean
		s.get_boolean
		fantastic_trader := s.last_boolean
		s.get_boolean
		telepathic := s.last_boolean
		s.get_boolean
		lucky := s.last_boolean
		s.get_boolean
		omniscient := s.last_boolean
		s.get_boolean
		stealthy := s.last_boolean
		s.get_boolean
		transdimensional := s.last_boolean
		s.get_boolean
		warlord := s.last_boolean
	end


end
