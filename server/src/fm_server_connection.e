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
            start
        when msgtype_turn then
            u.get_boolean
            next_turn (u.last_boolean)
        when msgtype_fleet then
            move_fleet (u)
        else
            Precursor (ptype)
        end
    end

    on_close is
    do
        if player /= Void then
            std_error.put_string (format(l("Connection from player ~1~@~2~:~3~ closed.%N"),
                                  <<player.name, dq_address, port>>))
            player.set_connection (Void)
            player := Void
            server.game.players.update_clients
        else
            std_error.put_string (format(l("Connection from ~1~:~2~ closed.%N"),
                                         <<dq_address, port>>))
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

    start is
        -- player ready to start game
    do
        if player = Void then
            std_error.put_string (l("Client error. Player asked to start without logging in first%N"))
        elseif player.state /= st_setup then
            std_error.put_string (format(l("Client error. Player ~1~ asked to start being in an invalid state.%N"),
                              <<player.name>>))
        else
            server.game.set_player_ready (player)
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
        fleet: FLEET
        destination: STAR
        ships: SET [SHIP]
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
        elseif ships.count = 0 then
            print ("move_fleet: non-positive ship count%N")
        elseif ships.count < count then
            print ("move_fleet: ships repeated or not in fleet%N")
        else
            -- Send orders
            server.game.galaxy.fleet_orders (fleet, destination, ships)
        end
    end
    
feature {NONE} -- Representation

    player: S_PLAYER
        -- player connected to this connection. Void before joining

invariant
    player /= Void implies player.connection = Current

end -- class FM_SERVER_CONNECTION