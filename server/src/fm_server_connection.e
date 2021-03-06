class FM_SERVER_CONNECTION

inherit
    SPP_SERVER_CONNECTION
    redefine
        on_new_package,
        on_close
    end
    PROTOCOL
    GETTEXT
    STRING_FORMATTER
    PLAYER_CONSTANTS
    TECHNOLOGY_TREE_ACCESS
    TECHNOLOGY_CONSTANTS

creation
    make

feature -- Creation

    make (s: FM_SERVER) is
    do
        server := s
        make_with_registry (server)
    end

feature -- Access

    server: FM_SERVER
        -- Server owning this connection

feature -- Redefined features

    on_new_package (ptype: INTEGER) is
    local
        user, pass: STRING
        u: UNSERIALIZER
    do
        !!u.start (buffer)
        inspect
            ptype
        when msgtype_join then
            u.get_string
            user := u.last_string
            u.get_string
            pass := u.last_string
            join (user, pass)
        when msgtype_rejoin then
            u.get_string
            user := u.last_string
            u.get_string
            pass := u.last_string
            rejoin (user, pass)
        when msgtype_start then
            start(u)
        when msgtype_turn then
            u.get_boolean
            next_turn (u.last_boolean)
        when msgtype_dialog then
            server.game.dialog_message (u)
        when msgtype_fleet then
            move_fleet (u)
        when msgtype_colonize then
            colonize(u)
        when msgtype_engage then
            engage(u)
        when msgtype_task then
            set_task(u)
        when msgtype_startbuilding then
            startbuilding(u)
        when msgtype_buy then
            buy_production(u)
        when msgtype_set_current_tech then
            set_current_tech(u)
        else
            Precursor (ptype)
        end
    end

    on_close is
    do
        if player /= Void then
            std_error.put_string (format(l("Connection from player ~1~@~2~:~3~ closed.%N"),
                                  <<player.name, dq_address, port.out>>))
            player.set_connection (Void)
            player := Void
            server.game.players.update_clients
        else
            std_error.put_string (format(l("Connection from ~1~:~2~ closed.%N"),
                                         <<dq_address, port.out>>))
        end
    end

feature {NONE} -- Operations: joining

    send_join_accept is
        -- send Join-Accept package
    do
        send_package (msgtype_join_accept, "")
    end

    send_join_reject (cause: INTEGER) is
        -- send Join-Reject package
    local
        s: SERIALIZER2
    do
        !!s.make
        s.add_integer (cause)
        send_package (msgtype_join_reject, s.serialized_form)
    end

    join (user, password: STRING) is
        -- Join `user' with given `password' if allowed, or send reject.
    do
        if server.game.players.has (user) then
            send_join_reject (reject_cause_duplicate)
        elseif server.game.status.open_slots = 0 then
            send_join_reject (reject_cause_noslots)
        elseif server.game.status.finished then
            send_join_reject (reject_cause_finished)
        elseif player /= Void then
            send_join_reject (reject_cause_relog)
        else
            !!player.make (user, password)
            player.set_connection (Current)
            server.game.add_player (player)
            send_join_accept
            std_error.put_string (format(l("Player '~1~' has joined.%N"),
                                         <<user>>))
        end
    end

    rejoin (user, password: STRING) is
        -- Rejoin `user' with given `password' if allowed, or send reject.
    do
        if not server.game.players.has (user) then
            send_join_reject (reject_cause_unknown)
        elseif not password.is_equal((server.game.players @ user).password) then
            send_join_reject (reject_cause_password)
        elseif server.game.status.finished then
            send_join_reject (reject_cause_finished)
        elseif player /= Void then
            send_join_reject (reject_cause_relog)
        else
            if (server.game.players @ user).connection = Void then
                player := server.game.players @ user
                send_join_accept
                player.set_connection (Current)
                std_error.put_string (format(l("Player '~1~' has rejoined.%N"),
                                             <<user>>))
                server.game.players.update_clients
            else
                send_join_reject (reject_cause_alreadylog)
            end
        end
    end

    start(u: UNSERIALIZER) is
        -- player ready to start game
    local
        ruler_name: STRING
        color: INTEGER
        it: ITERATOR[S_PLAYER]
        bad_setup: BOOLEAN
    do
        if player = Void then
            std_error.put_string (l("Client error. Player asked to start without logging in first%N"))
        elseif player.state /= st_setup then
            std_error.put_string (format(l("Client error. Player ~1~ asked to start being in an invalid state.%N"),
                              <<player.name>>))
        else
            u.get_integer
            color := u.last_integer
            u.get_string
            ruler_name := u.last_string
            player.race.unserialize_from(u)
            from
                it := server.game.players.get_new_iterator
            until
                it.is_off or bad_setup
            loop
                if it.item.state >= st_ready and then
                     (it.item.ruler_name.is_equal(ruler_name) or
                      it.item.race.picture = player.race.picture or
                      it.item.race.name.is_equal(player.race.name) or
                      it.item.color = color) then
                    std_error.put_string(l("Client error?  Ruler name, picture, race name or color already taken.%N"))
                    bad_setup := True
                end
                it.next
            end
            if not bad_setup then
                player.set_ruler_name(ruler_name)
                player.set_color(color)
                server.game.players.update_clients
                server.game.set_player_ready (player)
            end
        end
    end

feature {NONE} -- Operations

    next_turn (multiple: BOOLEAN) is
        -- player finished turn. `multiple' iff player wants to let several
        -- turns to pass
    do
        if player = Void then
            std_error.put_string (l("Client error. Player asked to pass turn without logging in before%N"))
        elseif player.state /= st_playing_turn then
            std_error.put_string (format(l("Client error. Player ~1~ asked to pass turn being in an invalid state.%N"),
                              <<player.name>>))
        else
-- Use multiple somehow
            server.game.end_turn (player)
        end
    end

    move_fleet (u: UNSERIALIZER) is
    local
        fleet: S_FLEET
        destination: S_STAR
        ships: HASHED_SET [S_SHIP]
        i, count: INTEGER
    do
        -- Unserialize
        u.get_integer
        if server.game.galaxy.has_fleet (u.last_integer) then
            fleet := server.game.galaxy.fleet_with_id (u.last_integer)
        end
        u.get_integer
        if server.game.galaxy.has_star (u.last_integer) then
            destination := server.game.galaxy.star_with_id (u.last_integer)
        end
        u.get_integer
        count := u.last_integer
        !!ships.with_capacity (count)
        from i := 1 until i > count loop
            u.get_integer
            if fleet /= Void and then fleet.has_ship (u.last_integer) then
                ships.add (fleet.ship (u.last_integer))
            end
            i:=i+1
        end
        -- Check consistency
        if fleet = Void then
            print ("move_fleet: Invalid fleet id%N")
        elseif fleet.owner /= player then
            print ("move_fleet: fleet is owned by somebody else%N")
        elseif destination = Void then
            print ("move_fleet: Invalid destination id%N")
        elseif not player.is_in_range(destination, fleet, ships) then
            print ("move_fleet: Destination out of range%N")
        elseif not fleet.can_receive_orders then
            print ("Cannot issue orders to that fleet at the moment%N")
        elseif ships.count = 0 then
            print ("move_fleet: non-positive ship count%N")
        elseif ships.count < count then
            print ("move_fleet: ships repeated or not in fleet%N")
        else
            -- Send orders
            server.game.galaxy.fleet_orders (fleet, destination, ships)
        end
    end


    set_task (u: UNSERIALIZER) is
    local
        pops: HASHED_SET [POPULATION_UNIT]
        pop_it: ITERATOR[POPULATION_UNIT]
        task, count, i: INTEGER
        colony: S_COLONY
    do
        -- Unserialize
        u.get_integer
        if player.colonies.has(u.last_integer) then
            colony := player.colonies @ u.last_integer
        end
        u.get_integer
        task := u.last_integer
        u.get_integer
        count := u.last_integer
        create pops.with_capacity (count)
        from i := 1 until i > count loop
            u.get_integer
            if colony /= Void and then colony.populators.has(u.last_integer) then
                pops.add (colony.populators @ u.last_integer)
            end
            i := i + 1
        end
        -- Check consistency
        if colony = Void then
            print ("set_task: Invalid colony id%N")
        elseif not task.in_range(0, 2) then
            print ("set_task: Invalid task%N")
        elseif count <= 0 then
            print ("set_task: Non-positive count%N")
        elseif pops.count < count then
            print ("set_task: Invalid population unit ids%N")
        else
            task := task + pops.item(pops.lower).task_farming
            from
                pop_it := pops.get_new_iterator
            until
                pop_it.is_off or else not pop_it.item.able(task)
            loop
                pop_it.next
            end
            if not pop_it.is_off then
                print ("set_task: Some population units are unable to perform this task")
            else
                -- Send orders
                colony.set_task(pops, task)
            end
        end
    end


    startbuilding (u: UNSERIALIZER) is
    local
        product_id: INTEGER
        product: CONSTRUCTION
        colony: S_COLONY
    do
        -- Unserialize
        u.get_integer
        if player.colonies.has(u.last_integer) then
            colony := player.colonies @ u.last_integer
        end
        u.get_integer
        product_id := u.last_integer + player.known_constructions.product_min
        if player.known_constructions.has(product_id) then
            product := player.known_constructions @ product_id
        end
        -- Check consistency
        if colony = Void then
            print ("startbuilding: Invalid colony id%N")
        elseif product = Void then
            print ("startbuilding: Invalid product Id%N")
        elseif colony.has_bought then
            print ("startbuilding: Colony has already bought this turn!%N")
        elseif not product.can_be_built_on(colony) then
            print ("startbuilding: " + product.name + " can't be built at colony " + colony.id.to_string + "%N")
        else
            colony.set_producing(product_id)
        end
    end

    buy_production(u: UNSERIALIZER) is
    local
        colony: S_COLONY
    do
        u.get_integer
        if player.colonies.has(u.last_integer) then
            colony := player.colonies @ u.last_integer
        end
        if colony = Void then
            print ("buy_producing: Invalid colony id%N")
        elseif colony.has_bought then
            print ("buy_producing: Colony has already bought this turn%N")
        elseif not colony.producing.is_buyable then
            print ("buy_producing: Product '" + colony.producing.name + "' isn't buyable%N")
        elseif player.money < colony.buying_price then
            print ("buy_producing: Insuficient funds%N")
        elseif colony.produced >= colony.producing.cost(colony) then
            print ("buy_producing: No production missing to buy")
        else
            colony.buy
        end
    end

    set_current_tech(u: UNSERIALIZER) is
    local
        tech_id: INTEGER
        tech: TECHNOLOGY
    do
        u.get_integer
        tech_id := u.last_integer + tech_min.item (category_construction)
        if not is_valid_tech_id(tech_id) then
            print ("set_current_tech: Invalid tech id%N")
        else
            tech := tech_tree.tech (tech_id)
            if not player.knowledge.next_field (tech.field.category.id).has (tech.id) then
                print ("set_current_tech: Tech not available to be researched%N")
            else
                player.knowledge.set_current_tech (tech)
            end
        end
    end

    colonize(u: UNSERIALIZER) is
    local
        fleet: S_FLEET
    do
        u.get_integer
        fleet := server.game.galaxy.fleet_with_id(u.last_integer)
        if fleet = Void then
            print("colonize: invalid fleet id%N")
        elseif fleet.orbit_center = Void then
            print("colonize: fleet not in orbit%N")
        elseif not fleet.orbit_center.has_colonizable_planet then
            print("colonize: no planets to colonize%N")
        elseif not fleet.can_colonize then
            print("colonize: Fleet cannot colonize%N")
        else
            fleet.colonize_order
        end
    end

    engage (u: UNSERIALIZER) is
    local
        fleet: S_FLEET
    do
        u.get_integer
        if server.game.galaxy.has_fleet (u.last_integer) then
            fleet := server.game.galaxy.fleet_with_id(u.last_integer)
        end
        if fleet = Void then
            print("engage: invalid fleet id%N")
        elseif fleet.orbit_center = Void then
            print("engage: fleet not in orbit%N")
        elseif not fleet.can_engage then
            print("engage: Fleet cannot engage%N")
        elseif not fleet.has_target_at (server.game.galaxy) then
            print("engage: no targets to engage%N")
        else
            fleet.engage_order
        end
    end

feature {NONE} -- Representation

    player: S_PLAYER
        -- player connected to this connection. Void before joining

invariant
    player /= Void implies player.connection = Current

end -- class FM_SERVER_CONNECTION
