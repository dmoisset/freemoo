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
        s: SERIALIZER
    do
        inspect
            ptype
        when msgtype_join then
            s.unserialize ("ss", buffer)
            user ?= s.unserialized_form @ 1
            pass ?= s.unserialized_form @ 2
            join (user, pass)
        when msgtype_rejoin then
            s.unserialize ("ss", buffer)
            user ?= s.unserialized_form @ 1
            pass ?= s.unserialized_form @ 2
            rejoin (user, pass)
        when msgtype_start then
            if player = Void then
                std_error.put_string (l("Client error. Player asked to start without login%N"))
            elseif player.state /= st_setup then
                std_error.put_string (format(l("Client error. Player ~1~ asked to start being in an invalid state.%N"),
                                  <<player.name>>))
            else
                server.game.set_player_ready (player)
            end
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
        s: SERIALIZER
    do
        s.serialize ("i", <<cause>>)
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

feature {NONE} -- Representation

    player: S_PLAYER
        -- player connected to this connection. Void before joining

invariant
    player /= Void implies player.connection = Current

end -- class FM_SERVER_CONNECTION