class S_PLAYER

inherit
    PLAYER
    rename
        make as player_make
    undefine
        copy, is_equal
    redefine
        add_to_known_list, add_to_visited_list, colony_type,
        star_type, race, set_ruler_name, set_race, set_color, add_colony,
        remove_colony, known_constructions, update_money, update_research,
        set_state, capitol_destroyed, capitol_built, knowledge
    select id end
    STORABLE
    rename
        hash_code as id
    redefine
        dependents, primary_keys, copy, is_equal
    end
    SERVICE
    undefine
        copy, is_equal
    redefine
        subscription_message
    end
    SERVER_ACCESS
    PRODUCTION_CONSTANTS

creation
    make

feature -- Redefined Features

    colony_type: S_COLONY

    star_type: S_STAR

    race: S_RACE

    known_constructions: S_CONSTRUCTION_REPO

    knowledge: S_KNOWLEDGE_BASE

feature {NONE} -- Creation

    make (new_name, new_password: STRING) is
    do
        name := clone (new_name)
        password := clone (new_password)
        player_make
        make_unique_id
    ensure
        name.is_equal (new_name)
        password.is_equal (new_password)
        state = st_setup
    end

feature -- Operations

    set_connection (new_connection: SPP_SERVER_CONNECTION) is
    do
        connection := new_connection
    ensure
        connection = new_connection
    end

    set_ruler_name(new_ruler_name: STRING) is
    do
        Precursor(new_ruler_name)
        update_clients
    end

    set_race(new_race: like race) is
    do
        Precursor(new_race)
        update_clients
    end

    set_color(new_color: INTEGER) is
    do
        Precursor(new_color)
        update_clients
    end

    update_clients is
    do
        -- Check to avoid updates on initialization
        if registry /= Void then
            send_message ("player" + id.to_string, subscription_message ("player" + id.to_string))
        end
    end

    send_turn_summary is
    do
        check registry /= Void end
        send_message (color.to_string + ":turn_summary", turn_summary_message)
        turn_summary.clear
    end

    serialize_on (s: SERIALIZER2) is
    local
        rlname, rcname: STRING
        race_picture: INTEGER
        race_id: INTEGER
    do
        rlname := ""
        rcname := ""
        if ruler_name /= Void then rlname := ruler_name end
        if race /= Void then
            race_picture := race.picture
            if race.name /= Void then rcname := race.name end
            race_id := race.id
        else
            race_picture := 0
        end
        s.add_tuple (<<id.box, name, rlname, rcname, race_id.box, race_picture.box,
                       color.box, state.box, (connection /= Void).box>>)
    end

feature -- Access

    password: STRING
        -- Player password

    connection: SPP_SERVER_CONNECTION
        -- Conection to client

    is_equal(other: like Current): BOOLEAN is
    do
        Result := id = other.id
    end

feature -- Redefined features

    subscription_message (service_id: STRING): STRING is
    local
        serv_id: STRING
        s: SERIALIZER2
        star_it: ITERATOR [like star_type]
        col_it: ITERATOR [COLONY]
    do
        -- Validate service_id
        if service_id.has_prefix("player") then
            create s.make
            create serv_id.copy(service_id)
            serv_id.remove_prefix("player")
            if serv_id.is_integer and then serv_id.to_integer = id then
                s.add_string(ruler_name)
                s.add_integer(money)
                s.add_integer(research)
                s.add_real(fuel_range)
                s.add_boolean(has_capitol)
                s.add_integer (knows_star.count)
                s.add_integer (has_visited_star.count)
                s.add_integer (colonies.count)
                star_it := knows_star.get_new_iterator
                from star_it.start until star_it.is_off loop
                    s.add_integer (star_it.item.id)
                    star_it.next
                end
                star_it := has_visited_star.get_new_iterator
                from star_it.start until star_it.is_off loop
                    s.add_integer (star_it.item.id)
                    star_it.next
                end
                col_it := colonies.get_new_iterator_on_items
                from col_it.start until col_it.is_off loop
                    s.add_integer (col_it.item.location.orbit_center.id)
                    s.add_integer (col_it.item.location.orbit)
                    s.add_integer (col_it.item.id)
                    col_it.next
                end
            end
            Result := s.serialized_form
        elseif service_id.is_equal(color.to_string + ":turn_summary") then
            Result := turn_summary_message
        end
    end

    turn_summary_message: STRING is
    local
        s: SERIALIZER2
        msg: ITERATOR[TURN_SUMMARY_ITEM]
    do
        create s.make
        s.add_integer (turn_summary.count)
        from
            msg := turn_summary.get_new_iterator
        until msg.is_off loop
            msg.item.serialize_on(s)
            msg.next
        end
        Result := s.serialized_form
    end

    add_to_known_list (star: like star_type) is
    do
        if not knows_star.has(star) then
            add_summary_message(create {TURN_SUMMARY_ITEM_EXPLORED}.make(star))
        end
        Precursor (star)
        update_clients
    end

    add_to_visited_list (star: like star_type) is
    do
        Precursor (star)
        update_clients
    end

feature {PLAYER_LIST} -- Operations

    set_state (new_state: INTEGER) is
    do
        Precursor(new_state)
        if new_state = st_playing_turn then
            send_turn_summary
        end
        state := new_state
    end

feature {COLONY} -- Redefined features

    add_colony(c: like colony_type) is
    local
        service_id: STRING
    do
        Precursor(c)
        service_id := "colony" + c.id.to_string
        if not server.has(service_id) then
            server.register(c, service_id)
        end
        update_clients
    end

    remove_colony(c: like colony_type) is
    do
        Precursor(c)
        server.unregister("colony" + c.id.to_string)
        update_clients
    end

feature -- Harvesting

    update_money(amount: INTEGER) is
    do
        Precursor(amount)
        update_clients
    end

    update_research(amount: INTEGER) is
    do
        Precursor(amount)
        update_clients
    end

feature {CONSTRUCTION} -- Operations

    capitol_built is
    do
        Precursor
        update_clients
    end

    capitol_destroyed is
    do
        Precursor
        update_clients
    end

feature -- Operations

    copy(other: like Current) is
    do
        standard_copy(other)
        colonies := clone(other.colonies)
        create known_constructions.make -- Known constructions aren't copied
        knows_star := clone(other.knows_star)
        has_visited_star := clone(other.has_visited_star)
        turn_summary := clone(other.turn_summary)
    end

feature {STORAGE} -- Saving

    get_class: STRING is "PLAYER"

    fields: ITERATOR[TUPLE[STRING, ANY]] is
    local
        a: ARRAY[TUPLE[STRING, ANY]]
        const_it: ITERATOR[CONSTRUCTION]
        starship: S_SHIP_CONSTRUCTION
    do
        create a.make(1, 0)
        a.add_last(["ruler_name", ruler_name])
        a.add_last(["money", money.box])
        a.add_last(["research", money.box])
        a.add_last(["color", color.box])
        a.add_last(["state", state.box])
        a.add_last(["password", password])
        a.add_last(["race", race])
        a.add_last(["fuel_range", fuel_range.box])
        a.add_last(["has_capitol", has_capitol.box])
        a.add_last(["knowledge", knowledge])
        add_to_fields(a, "colony", colonies.get_new_iterator_on_items)
        add_to_fields(a, "knows_star", knows_star.get_new_iterator)
        add_to_fields(a, "has_visited_star", has_visited_star.get_new_iterator)
        from
            const_it := known_constructions.get_new_iterator
        until
            const_it.is_off
        loop
            starship ?= const_it.item
            if starship /= Void and then starship.id > product_max then
                a.add_last(["design" + (starship.id - product_min).to_string, starship.design])
            else
                a.add_last(["construction" + (const_it.item.id - product_min).to_string,
                            (const_it.item.id - product_min).box]) -- Redundant redundancy
            end
            const_it.next
        end
        Result := a.get_new_iterator
    end

    primary_keys: ITERATOR[TUPLE[STRING, ANY]] is
    do
        Result := (<<["id", id.box],
                     ["name", name]
                     >>).get_new_iterator
    end

    dependents: ITERATOR[STORABLE] is
    local
        a: ARRAY[STORABLE]
        const_it: ITERATOR[CONSTRUCTION]
        starship: S_SHIP_CONSTRUCTION
    do
        create a.make(1, 0)
        a.add_last (race)
        a.add_last (knowledge)
        add_dependents_to(a, colonies.get_new_iterator_on_items)
        knows_star.do_all(agent a.add_last)
        has_visited_star.do_all(agent a.add_last)
        from
            const_it := known_constructions.get_new_iterator
        until
            const_it.is_off
        loop
            starship ?= const_it.item
            if const_it.item.id > product_max and starship /= Void then
                a.add_last(starship.design)
            end
            const_it.next
        end
        Result := a.get_new_iterator
    end

feature {STORAGE} -- Retrieving

    set_primary_keys (elems: ITERATOR [TUPLE [STRING, ANY]]) is
    local
        i: REFERENCE [INTEGER]
    do
        from
        until elems.is_off loop
            if elems.item.first.is_equal("id") then
                i ?= elems.item.second
                set_id(i.item)
            end
            if elems.item.first.is_equal("name") then
                name ?= elems.item.second
            end
            elems.next
        end
    end

feature {STORAGE} -- Retrieving

    make_from_storage (elems: ITERATOR [TUPLE [STRING, ANY]]) is
    local
        i: REFERENCE[INTEGER]
        r: REFERENCE[REAL]
        b: REFERENCE[BOOLEAN]
        colony: S_COLONY
        star: S_STAR
        design: S_STARSHIP
        product: INTEGER
    do
        from
            colonies.clear
            knows_star.clear
            has_visited_star.clear
        until elems.is_off loop
            if elems.item.first.is_equal("ruler_name") then
                ruler_name ?= elems.item.second
            elseif elems.item.first.is_equal("money") then
                i ?= elems.item.second
                money := i.item
            elseif elems.item.first.is_equal("research") then
                i ?= elems.item.second
                research := i.item
            elseif elems.item.first.is_equal("password") then
                password ?= elems.item.second
            elseif elems.item.first.is_equal("color") then
                i ?= elems.item.second
                color := i.item
            elseif elems.item.first.is_equal("fuel_range") then
                r ?= elems.item.second
                fuel_range := r.item
            elseif elems.item.first.is_equal("has_capitol") then
                b ?= elems.item.second
                has_capitol := b.item
            elseif elems.item.first.is_equal("state") then
                i ?= elems.item.second
                state := i.item
            elseif elems.item.first.is_equal("race") then
                race ?= elems.item.second
            elseif elems.item.first.is_equal("knowledge") then
                knowledge ?= elems.item.second
            elseif elems.item.first.has_prefix("colony") then
                colony ?= elems.item.second
                add_colony (colony)
            elseif elems.item.first.has_prefix("knows_star") then
                star ?= elems.item.second
                knows_star.add(star)
            elseif elems.item.first.has_prefix("has_visited_star") then
                star ?= elems.item.second
                has_visited_star.add(star)
            elseif elems.item.first.has_prefix("construction") then
                i ?= elems.item.second
                product := i.item + product_min
                if not known_constructions.has(product) then
                    known_constructions.add_by_id(product)
                end
            elseif elems.item.first.has_prefix("design") then
                design ?= elems.item.second
                known_constructions.add_starship_design(design)
            else
                print ("Bad element inside 'player' tag: " + elems.item.first + "%N")
            end
            elems.next
        end
    end

end -- class S_PLAYER
