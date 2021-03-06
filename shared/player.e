class PLAYER

inherit
    PLAYER_CONSTANTS
    UNIQUE_ID
    SHIP_CONSTANTS

feature {NONE} -- Creation

    make is
    do
        set_state (st_setup)
        set_color (min_color)
        create race.make
        create colonies.make
        create knows_star.make
        create has_visited_star.make
        create known_constructions.make
        create knowledge.make
        create turn_summary.make(1, 0)
        ruler_name := ""
    ensure
        state = st_setup
        money = 0
    end

feature -- Access

    name: STRING
        -- Player name

    color: INTEGER
        -- a unique color

    colonies: HASHED_DICTIONARY [like colony_type, INTEGER]
        -- Colonies owned by this player

    knows_star: HASHED_SET[like star_type]
        -- Stars known by this player

    has_visited_star: HASHED_SET[like star_type]
        -- Stars visited by this player

    known_constructions: CONSTRUCTION_REPO
        -- Constructions this player can build

    fuel_range: REAL
        -- Distance our ships can travel from our colonies

    drive_speed: REAL
        -- Speed our ships travel at (interstellar parsecs per turn, not combat speed)

    ruler_name: STRING

    money: INTEGER

    research: INTEGER

    has_capitol: BOOLEAN
        -- True when this player has a capitol on some colony
        -- (very bad if false...)

    race: RACE
        -- The race this player rules

    knowledge: KNOWLEDGE_BASE
        -- This player's knowledge base.

    iterator_on_turn_summary: ITERATOR[TURN_SUMMARY_ITEM] is
        -- Get a new iterator on this turn's events
    do
        Result := turn_summary.get_new_iterator
    end

feature -- Access

    --
    -- The player moves through a simple state loop. Possible `state' is:
    --   st_setup: Selecting race name, options, color, etc.
    --   st_ready: Waiting for game to begin
    --   st_playing_turn: Doing main turn actions (giving orders to fleets,
    --                    colonies), etc.
    --   st_waiting_turn_end: finished giving turn orders, waiting for others.
    --   st_end_game: The game is over for this player.

    state: INTEGER
        -- State on the game

feature -- Query

    is_in_range(dest: STAR; fleet: FLEET; ss: HASHED_SET[SHIP]): BOOLEAN is
        -- Can these ships reach dest with our current fuel range?
    require
        dest /= Void
        fleet /= Void
        ss /= Void
    local
        shp_it: ITERATOR[SHIP]
        col_it: ITERATOR[like colony_type]
        fuel_factor: REAL
    do
        -- Consider wormholes
        if fleet.orbit_center /= Void and then
           fleet.orbit_center.wormhole = dest then
            Result := True
        else
        -- Consider different ships' fuel range
            from
                fuel_factor := 1000 -- Infinity
                shp_it := ss.get_new_iterator
            until
                shp_it.is_off
            loop
                fuel_factor := fuel_factor.min(shp_it.item.fuel_range)
                shp_it.next
            end
            from
                col_it := colonies.get_new_iterator_on_items
            until col_it.is_off or Result = True loop
                if col_it.item.location.orbit_center |-| dest < fuel_range * fuel_factor then
                    Result := True
                end
                col_it.next
            end
        end
    end

    max_population_on(p: PLANET): INTEGER is
    -- Maximum population for a colony on `p', without considering colony's constructions
    require
        p /= Void
    do
        -- Consider aquatic bonus
        if race.aquatic then
            Result := p.aquatic_maxpop
        else
            Result := p.base_maxpop
        end
        -- Consider tolerant bonus
        if race.tolerant then
            Result := Result.max(p.tolerant_maxpop)
        end
        -- Consider subterranean bonus
        if race.subterranean then
            Result := Result + p.subterranean_maxpop_bonus
        end
        -- Consider advances
        -- ... (Advanced City Planning)...
    end

feature {PLAYER_LIST} -- Operations

    set_state (new_state: INTEGER) is
    require
        new_state.in_range (min_state, max_state)
    do
        state := new_state
    ensure
        state = new_state
    end

    set_color (new_color: INTEGER) is
    require
        new_color.in_range (min_color, max_color)
    do
        color := new_color
    ensure
        color = new_color
    end

    set_ruler_name(new_ruler_name: STRING) is
    require
        new_ruler_name /= Void
    do
        ruler_name := new_ruler_name
    ensure
        ruler_name = new_ruler_name
    end

    set_race(new_race: like race) is
    require
        new_race /= Void
    do
        race := new_race
    ensure
        race = new_race
    end
feature {PLAYER_LIST, TECHNOLOGY} -- Operations

    set_fuel_range (new_range: REAL) is
    require
        new_range > 0
    do
        fuel_range := new_range
    ensure
        fuel_range = new_range
    end

    set_drive_speed (new_speed: REAL) is
    require
        new_speed > 0
    do
        drive_speed := new_speed
    ensure
        drive_speed = new_speed
    end

feature {COLONY} -- Operations

    add_colony (colony: like colony_type) is
    require
        not colonies.has (colony.id)
    do
        colonies.add (colony, colony.id)
    ensure
        colonies.has (colony.id)
    end

    remove_colony (colony: like colony_type) is
    require
        colonies.has (colony.id)
    do
        colonies.remove (colony.id)
    ensure
        not colonies.has (colony.id)
    end

feature -- Operations

    update_money(amount: INTEGER) is
    require money + amount >= 0
    do
        money := money + amount
    ensure
        money = old money + amount
    end

    update_research(amount: INTEGER) is
    do
        research := research + amount
    ensure
        research = old research + amount
    end

    add_summary_message(msg: TURN_SUMMARY_ITEM) is
    require
        msg /= Void
    do
        turn_summary.add_last(msg)
    end

    check_basic_ship_tech is
    local
--        it: ITERATOR[TECHNOLOGY]
--        armor_tech: TECHNOLOGY_ARMOR
        size: INTEGER
        has_armor: BOOLEAN
        starship: like starship_type
    do
        if fuel_range > 0 and drive_speed > 0 then
--            from
--                it := knowledge.iterator_on_known_techs
--            until
--                it.is_off or has_armor
--            loop
--                armor_tech ?= it.item
--                has_armor := armor_tech /= Void
--                it.next
--            end
            has_armor := True
            if has_armor then
                from
                    size := ship_size_frigate
                until
                    size > ship_size_battleship
                loop
                    create starship.make (Current)
                    starship.set_name (ship_names @ size)
                    starship.set_size (size)
                    known_constructions.add_starship_design (starship)
                    size := size + 1
                end
            end
        end
    end

feature {NONE} -- Auxiliar

    ship_names: ARRAY[STRING] is
    once
        Result := <<"Scout", "Sparrow", "Squid", "Shredder", "Siegemaster", "Sorrowbringer">>
        Result.reindex (ship_size_frigate)
    ensure
        Result.lower = ship_size_frigate
        Result.upper = ship_size_doomstar
    end

feature {CONSTRUCTION} -- Operations

    capitol_destroyed is
    require
        has_capitol
    do
        has_capitol := False
    ensure
        not has_capitol
    end

    capitol_built is
    require
        not has_capitol
    do
        has_capitol := True
    ensure
        has_capitol
    end

feature {MAP_GENERATOR, FLEET}

    add_to_known_list (star: like star_type) is
    do
        knows_star.add (star)
    end

    add_to_visited_list (star: like star_type) is
    do
        has_visited_star.add (star)
    end

feature {PLAYER} -- Internal

    turn_summary: ARRAY[TURN_SUMMARY_ITEM]

feature -- Anchors

    construction_type: CONSTRUCTION

    colony_type: COLONY

    star_type: STAR

    starship_type: STARSHIP

invariant
    race /= Void
    ruler_name /= Void
    valid_state: state.in_range (min_state, max_state)
    valid_color: color.in_range (min_color, max_color)
end -- class PLAYER
