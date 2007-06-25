class C_PLAYER
    -- Should subscribe after galaxy

inherit
    PLAYER
    rename
        make as player_make
    redefine colony_type, race, known_constructions, knowledge end
    TURN_SUMMARY_CONSTANTS
    SUBSCRIBER
    CLIENT

creation
    make

feature {NONE} -- Creation

    make (new_name: STRING) is
    do
        make_unique_id
        name := clone (new_name)
        create colonies_changed.make
        create turn_summary_changed.make
        player_make
    ensure
        name.is_equal (new_name)
    end

feature -- Operations

    unserialize_from (s: UNSERIALIZER) is
        -- Update from `s'.
    local
        race_name: STRING
    do
        if race = Void then
            !!race.make
        end
        s.get_string
        set_ruler_name(s.last_string)
        s.get_string
        race_name := s.last_string
        s.get_integer
        race := server.xeno_repository.item(s.last_integer)
        s.get_integer; race.set_picture(s.last_integer)
        s.get_integer; set_color (s.last_integer)
        s.get_integer; set_state (s.last_integer)
        s.get_boolean; connected := s.last_boolean
    end

feature {SERVICE_PROVIDER} -- Subscriber callback

    on_message (msg: STRING; provider: SERVICE_PROVIDER; service: STRING) is
        -- Action when `msg' arrives from `provider''s `service'
    do
        if service.is_equal(color.to_string + ":turn_summary") then
            decode_turn_summary_message(msg, provider)
        elseif service.is_equal("player" + id.to_string) then
            decode_player_message(msg, provider)
        else
            check unexpected_service: False end
        end
    end

    decode_player_message(msg: STRING; provider: SERVICE_PROVIDER) is
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
        create s.start (msg)
        s.get_string
        ruler_name := s.last_string
        s.get_integer
        money := s.last_integer
        s.get_integer
        research := s.last_integer
        s.get_real
        fuel_range := s.last_real
        s.get_boolean
        has_capitol := s.last_boolean
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
                    -- Not doing it implies we re-suscribe to the star service for
                    -- ALL stars
                    star.subscribe (server, "star"+star.id.to_string)
                else
                    old_knows.remove (star)
                end
            else
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
                    colony.changed.connect(agent update_colony_variation)
                    colony.set_id(s.last_integer)
                else
                    colony := planet.colony
-- What if a somebody bombards and then recolonizes? The next check might fail
                    check colony.id = s.last_integer end
                    add_colony(colony)
                end
                if not old_colonies.has (colony.id) then
                    colony.subscribe (server, "colony"+colony.id.to_string)
                end
                old_colonies.remove (colony.id)
            else
                print ("c_player::on_message() - Warning: server reported that we have a colony on a star that isn%'t!%N")
            end
            colony_count := colony_count - 1
        end
        colonies_changed.emit(Current)
    end

    decode_turn_summary_message(msg: STRING; provider: SERVICE_PROVIDER) is
    require
        msg.count >= 4
    local
        u: UNSERIALIZER
        count, kind: INTEGER
        event: TURN_SUMMARY_ITEM
    do
        create u.start(msg)
        u.get_integer
        count := u.last_integer
        turn_summary.clear
        from variant count until count = 0 loop
            u.get_integer
            kind := u.last_integer + event_min
            inspect kind
            when event_explored then
                create {C_TURN_SUMMARY_ITEM_EXPLORED}event.unserialize_from(u)
            when event_finished_production then
                create {C_TURN_SUMMARY_ITEM_PRODUCED}event.unserialize_from(u)
            when event_starvation then
                create {C_TURN_SUMMARY_ITEM_STARVATION}event.unserialize_from(u)
            when event_researched then
                create {C_TURN_SUMMARY_ITEM_RESEARCH}event.unserialize_from(u)
            else
                check unexpected_event_kind: False end
            end
            turn_summary.add_last(event)
            count := count - 1
        end
        if turn_summary.count > 0 then
            turn_summary_changed.emit(Current)
        end
    end

feature -- Callbacks

    update_colony_variation is
    local
        col_it: ITERATOR[like colony_type]
    do
        from
            money_variation := 0
            research_variation := 0
            col_it := colonies.get_new_iterator_on_items
        until
            col_it.is_off
        loop
            money_variation := money_variation + col_it.item.money.total.rounded
            research_variation := research_variation + col_it.item.science.total.rounded
            col_it.next
        end
        colonies_changed.emit(Current)
    end

feature -- Signals

    colonies_changed: SIGNAL_1[C_PLAYER]

    turn_summary_changed: SIGNAL_1[C_PLAYER]

feature -- Access

    money_variation: INTEGER

    research_variation: INTEGER

    connected: BOOLEAN
        -- Player has a connection to the server

    known_constructions: C_CONSTRUCTION_REPO

feature -- Anchors

    race: C_RACE

    colony_type: C_COLONY

    knowledge: C_KNOWLEDGE_BASE

end -- class C_PLAYER
