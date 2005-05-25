class FM_CLIENT_CONNECTION

inherit
    NETWORK_SERVICE_PROVIDER
    redefine
        make,
        on_new_package,
        close
    end
    PROTOCOL
    PLAYER_CONSTANTS
    GETTEXT

creation
    make

feature -- Creation

    make (registry_host: STRING; registry_port: INTEGER) is
        -- New connection to server at `registry_host':`registry_port'
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

feature -- Operations -- Login commands

    join (name, password: STRING) is
        -- Join in server as `name' using given `password'
    require
        name /= Void and password /= Void
        not is_closed
        not is_joining and not has_joined
    local
        s: SERIALIZER2
    do
        !!s.make
        s.add_tuple (<<name, password>>)
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
        not is_joining and not has_joined
    local
        s: SERIALIZER2
    do
        !!s.make
        s.add_tuple (<<name, password>>)
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

    subscribe_init is
        -- subscribe to services provided on beginning
    require 
	player /= Void
    do
        subscribe (galaxy, "galaxy")
        subscribe (galaxy, player.id.to_string+":scanner")
        subscribe (galaxy, player.id.to_string+":new_fleets")
        subscribe (player, "player"+player.id.to_string)
    end

feature -- Operations -- Game commands

    end_turn (multiple: BOOLEAN) is
        -- Notify server that player has finished_turn
        -- if `multiple', player allows more than one turn to pass.
    local
        s: SERIALIZER2
    do
        !!s.make
        s.add_tuple (<<multiple>>)
        send_package (msgtype_turn, s.serialized_form)
        player_list.set_player_state (player, st_waiting_turn_end)
    end


    save_game  is
        -- Ask server to save game
    local
        s: SERIALIZER2
    do

        !!s.make
-- FIXME: uncomment when anthony finishis changes about save
--        send_package (msgtype_save, s.serialized_form)
    end

    move_fleet (f: FLEET; dest: STAR; ships: SET [SHIP]) is
        -- Send server a request to move `ships' of `f' toward `dest'
    require
        f/= Void and dest /= Void and ships /= Void
        not ships.is_empty
        owned_fleet: f.owner = player
--        ships_in_fleet: ships.for_all (agent f.has_ship (?))
    local
        s: SERIALIZER2
        i: ITERATOR [SHIP]
    do
        !!s.make
        s.add_tuple (<<f.id, dest.id, ships.count>>)
        from i := ships.get_new_iterator until i.is_off loop
            s.add_integer (i.item.id)
            i.next
        end
        send_package (msgtype_fleet, s.serialized_form)
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
        has_joined := False
        player := Void
        player_name := Void
        Precursor
    end

feature -- Access

    is_joining: BOOLEAN
        -- True when awaiting (re)join accept/reject

    is_joined: BOOLEAN is
    obsolete "Renamed to has_joined"
    do Result := has_joined end

    has_joined: BOOLEAN
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
        s: UNSERIALIZER
    do
        !!s.start (buffer)
        inspect
            ptype
        when msgtype_join_accept then
            if is_joining then
                is_joining := False
                has_joined := True
                player := player_list @ player_name
            else -- package arrived and shouldn't. Ignore
                std_error.put_string (l("Warning: received unrequested Join-Accept%N"))
            end
        when msgtype_join_reject then
            if is_joining then
                is_joining := False
                s.get_integer
                join_reject_cause := s.last_integer
            else -- package arrived and shouldn't. Ignore
                std_error.put_string (l("Warning: received unrequested Join-Reject%N"))
            end
        else
            Precursor (ptype)
        end
    end

invariant
    is_joining implies not has_joined

end -- class FM_CLIENT_CONNECTION
