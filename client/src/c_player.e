class C_PLAYER
    -- Should subscribe after galaxy

inherit
    PLAYER
    rename 
        make as player_make
    redefine colony_type end
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
        if race = Void then
            !!race.make
        end
        s.get_string; set_ruler_name(s.last_string)
        s.get_string; race.set_name(s.last_string)
        s.get_integer; race.set_picture(s.last_integer)
        s.get_integer; set_color (s.last_integer)
        s.get_integer; set_state (s.last_integer)
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
        old_knows: like knows_star
        old_colonies: like colonies
        colony: C_COLONY
        planet: C_PLANET
    do
        !!s.start (msg)
        s.get_string
        ruler_name := s.last_string
        s.get_integer
        money := s.last_integer
        s.get_real
        fuel_range := s.last_real
        s.get_integer
        knows_count := s.last_integer
        s.get_integer
        visited_count := s.last_integer
        s.get_integer
        colony_count := s.last_integer
        from
            old_knows := clone (knows_star)
            knows_star.clear
        until knows_count = 0 loop
            s.get_integer
            if server.galaxy.has_star (s.last_integer) then
                star := server.galaxy.star_with_id (s.last_integer)
                knows_star.add (star)
                if not old_knows.has (star) then 
                    -- We do the above check to avoid network overhead
                    -- Not doing iit implies we re-suscribe to the star service for
                    -- ALL stars
                    star.subscribe (server, "star"+star.id.to_string)
                else
                    old_knows.remove (star)
                end
            else
                print ("c_player::on_message() - Warning: server reported that we know a star that isn%'t!%N")
            end
            knows_count := knows_count - 1
        end
        -- Assumption: A player never forgets about a star:
        check old_knows.is_empty end
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
            old_colonies := clone (colonies)
            colonies.clear
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
                    star.set_planet(create{C_PLANET}.make_standard (star), orbit)
                    planet := star.planet_at(orbit)
                end
                s.get_integer
                if planet.colony = Void then
                    create colony.make(planet, Current)
                    colony.set_id(s.last_integer)
                else
                    colony := planet.colony
-- What if a somebody bombards and then recolonizes? The next check might fail
                    check colony.id = s.last_integer end
                end
                colonies.add (colony, colony.id)
                if not old_colonies.has (colony.id) then 
                    colony.subscribe (server, "colony"+colony.id.to_string)
                else
                    old_colonies.remove (colony.id)
                end
                colony.unserialize_from(s)
            else
                print ("c_player::on_message() - Warning: server reported that we have a colony on a star that isn%'t!%N")
            end
            colony_count := colony_count - 1
        end
    end

feature -- Access

    connected: BOOLEAN
        -- Player has a connection to the server

feature -- Anchors

    colony_type: C_COLONY

end -- class C_PLAYER
