class C_PLAYER
    -- Should subscribe after galaxy

inherit
    PLAYER
    rename make as player_make end
    SUBSCRIBER
    CLIENT

creation
    make

feature {NONE} -- Creation

    make (new_name: STRING) is
    do
        make_unique_id
        name := clone (new_name)
        player_make
    ensure
        name.is_equal (new_name)
    end

feature -- Operations

    unserialize_from (s: UNSERIALIZER) is
        -- Update from `s'.
    do
        s.get_integer; set_state (s.last_integer)
        s.get_integer; set_color (s.last_integer)
        s.get_boolean; connected := s.last_boolean
    end

feature {SERVICE_PROVIDER} -- Subscriber callback

    on_message (msg: STRING; provider: SERVICE_PROVIDER; service: STRING) is
        -- Action when `msg' arrives from `provider''s `service'
    local
        s: UNSERIALIZER
        knows_count, visited_count, colony_count: INTEGER
	orbit: INTEGER
        star: C_STAR
        old_list: like knows_star
	colony: COLONY
	planet: PLANET
    do
        !!s.start (msg)
	s.get_boolean
	is_telepathic := s.last_boolean
	s.get_real
	fuel_range := s.last_real
        s.get_integer
	knows_count := s.last_integer
	s.get_integer
	visited_count := s.last_integer
	s.get_integer
	colony_count := s.last_integer
        from
            old_list := clone (knows_star)
            knows_star.clear
        until knows_count = 0 loop
            s.get_integer
            if server.galaxy.has_star (s.last_integer) then
                star := server.galaxy.star_with_id (s.last_integer)
                knows_star.add (star)
                if not old_list.has (star) then 
                    -- We do the above check to avoid network overhead
                    -- Not doing iit implies we re-suscribe to the star service for
                    -- ALL stars
                    star.subscribe (server, "star"+star.id.to_string)
                else
                    old_list.remove (star)
                end
            else
                print ("c_player::on_message() - Warning: server reported that we know an star that isn%'t!%N")
            end
            knows_count := knows_count - 1
        end
	-- Assumption: A player never forgets about a star:
	check old_list.is_empty end
        from
        until visited_count = 0 loop
            s.get_integer
            if server.galaxy.has_star (s.last_integer) then
                star := server.galaxy.star_with_id (s.last_integer)
                has_visited_star.add (star)
            else
                print ("c_player::on_message() - Warning: server reported that we've visited an impossible star!%N")
            end
            visited_count := visited_count - 1
        end
	
	from
	until colony_count = 0 loop
	    s.get_integer
            if server.galaxy.has_star (s.last_integer) then
                star := server.galaxy.star_with_id (s.last_integer)
		s.get_integer
		orbit := s.last_integer
		planet := star.planet_at(orbit)
		if planet = Void then
		    -- Probably star information is on it's way, just
		    -- make do with what we have.
		    star.set_planet(create{PLANET}.make_standard (star), orbit)
		    planet := star.planet_at(orbit)
		end

		if planet.colony = Void then
		    create colony.make(planet, Current)
		else
		    colony := planet.colony
		end
		colony.unserialize_from(s)
	    else
                print ("c_player::on_message() - Warning: server reported that we've got a colony on a star!%N")
            end
	    
	    colony_count := colony_count - 1
	end
    end

feature -- Access

    connected: BOOLEAN
        -- Player has a connection to the server

end -- class C_PLAYER
