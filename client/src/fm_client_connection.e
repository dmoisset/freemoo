class FM_CLIENT_CONNECTION

inherit
    NETWORK_SERVICE_PROVIDER
    redefine
        make,
        on_new_package,
        close
    end
    PROTOCOL
    GETTEXT

creation
    make

feature -- Creation

    make (registry_host: STRING; registry_port: INTEGER) is
        -- New connection to server at `registry_host':`registry_port'
    require
        registry_host /= Void
    do
        Precursor (registry_host, registry_port)
        if game_status = Void then !!game_status.make end
        if player_list = Void then !!player_list.make end
        if galaxy = Void then !!galaxy.make end
    rescue
        if is_opening or not is_closed then
            close
        end
    end

feature -- Operations

    join (name, password: STRING) is
        -- Join in server as `name' using given `password'
    require
        name /= Void and password /= Void
        not is_closed
        not is_joining and not is_joined
    local
        s: SERIALIZER
    do
        s.serialize ("ss", <<name, password>>)
        send_package (msgtype_join, s.serialized_form)
        player_name := name
        is_joining := True
    ensure
        is_joining
    end

    rejoin (name, password: STRING) is
        -- Rejoin in server as `name' with given `password'
    require
        name /= Void and password /= Void
        not is_closed
        not is_joining and not is_joined
    local
        s: SERIALIZER
    do
        s.serialize ("ss", <<name, password>>)
        send_package (msgtype_rejoin, s.serialized_form)
        player_name := name
        is_joining := True
    ensure
        is_joining
    end

    set_ready is
        -- Notify server that player is ready to begin
    do
        send_package (msgtype_start, "")
    end

    subscribe_base is
        -- subscribe to basic services
    require
        not is_closed
        has ("game_status")
        has ("players_list")
    do
        subscribe (game_status, "game_status")
        subscribe (player_list, "players_list")
    end

    suscribe_init is
        -- subscribe to services provided on beginning
    do
        subscribe (galaxy, "galaxy")
    end

    end_turn (multiple: BOOLEAN) is
        -- Notify server that player has finished_turn
        -- if `multiple', player allows more than one turn to pass.
    local
        s: SERIALIZER
    do
        s.serialize ("b", <<multiple>>)
        send_package (msgtype_turn, s.serialized_form)
    end

    close is
    do
        if not remote_close then
            if subscribed_to (game_status, "game_status") then
                unsubscribe (game_status, "game_status")
            end
            if subscribed_to (player_list, "players_list") then
                unsubscribe (player_list, "players_list")
            end
        end
        is_joining := False
        is_joined := False
        player := Void
        player_name := Void
        Precursor
    end

feature -- Access

    is_joining: BOOLEAN
        -- True when awaiting (re)join accept/reject

    is_joined: BOOLEAN
        -- True after server accepted (re)join

    join_reject_cause: INTEGER
        -- Valid after failing to join

feature -- Access (server attributes)

    game_status: C_GAME_STATUS
        -- status of the game.

    player_list: C_PLAYER_LIST
        -- list of players.

    galaxy: C_GALAXY
        -- game map

    player: C_PLAYER
        -- Player at this client

    player_name: STRING
        -- Name of the player at this client

feature -- Redefined features

    on_new_package (ptype: INTEGER) is
        -- Handle incoming packages
    local
        ir: INTEGER_REF
        s: SERIALIZER
    do
        inspect
            ptype
        when msgtype_join_accept then
            if is_joining then
                is_joining := False
                is_joined := True
                player := player_list @ player_name
            else -- package arrived and shouldn't. Ignore
                std_error.put_string (l("Warning: received unrequested Join-Accept%N"))
            end
        when msgtype_join_reject then
            if is_joining then
                is_joining := False
                s.unserialize ("i", buffer)
                ir ?= s.unserialized_form @ 1
                join_reject_cause := ir.item
            else -- package arrived and shouldn't. Ignore
                std_error.put_string (l("Warning: received unrequested Join-Reject%N"))
            end
        else
            Precursor (ptype)
        end
    end

invariant
    is_joining implies not is_joined

end -- class FM_CLIENT_CONNECTION