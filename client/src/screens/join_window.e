class JOIN_WINDOW
    -- Window for joining to the game

inherit
    JOIN_WINDOW_GUI
    redefine handle_event end
    GETTEXT
    CLIENT
    STRING_FORMATTER
    PROTOCOL

creation
    make

feature -- Redefined features

    handle_event (event:EVENT) is
    local
        n: EVENT_NETWORK
    do
        Precursor (event)
        n ?= event
        if n /= Void then
            on_network
        end
    end

feature -- Operations

    activate is
        -- Show window
    require
        server /= Void
        not server.is_closed
        not server.is_joining
        not server.has_joined
    do
        show
        title_label.set_text (format(l("Connected to ~1~:~2~"),
                                     <<server.dq_address, server.port>>))
        status_label.set_text (
            l("Join as new player or rejoin as existing one."))
        name.grab
        show
        join_button.show
        joining := False
    end

feature {NONE} -- Callbacks

    destroy is
        -- Close and hide window
    do
        hide
    end

    join is
        -- Join button clicked
    do
        rejoin := server.player_list.has (name.text)
        if rejoin then
            server.rejoin (name.text, password.text)
        else
            server.join (name.text, password.text)
        end
        joining := True
        join_button.hide
    end

    disconnect is
        -- Disconnect button clicked
    do
        server.close
        destroy
    end

    on_network is
    do
        if not server.is_closed then
            if server.has_joined then
                joining := False
                destroy
            end
            if joining and not server.is_joining then
                joining := False
                join_button.show
                if rejoin then
                    status_label.set_text(
                        format (l("Can't rejoin: ~1~"), <<
                        rejoin_reject_causes @ server.join_reject_cause>>)
                    )
                else
                    status_label.set_text(
                        format (l("Can't join: ~1~"), <<
                        join_reject_causes @ server.join_reject_cause>>)
                    )
                end
            end
        else -- Connection lost
            destroy
        end
    end

feature {NONE} -- Internal

    joining: BOOLEAN
        -- True when the Join button until the server accepts or
        -- rejects the join.

    rejoin: BOOLEAN
        -- The last operation was a rejoin

feature {NONE} -- Widgets
    new_player_list (where: RECTANGLE) is
    do
        !!player_list.make (Current, where, server.player_list)
    end

    new_server_rules (where: RECTANGLE) is
    do
        !!server_rules.make (Current, where, server.game_status)
    end

feature {NONE} -- Constants

    join_reject_causes: ARRAY [STRING] is
    once
        !!Result.make (reject_cause_duplicate, max_reject_cause)
        Result.put (l("Another player with that name is playing"), reject_cause_duplicate)
        Result.put (l("No room for more players"), reject_cause_noslots)
        Result.put (l("Game has finished"), reject_cause_finished)
        Result.put (l("Access denied"), reject_cause_denied)
        Result.put (l("You are already logged in"), reject_cause_relog)
        Result.put (l("That player is already logged in"), reject_cause_alreadylog)
    end

    rejoin_reject_causes: ARRAY [STRING] is
    once
        !!Result.make (reject_cause_duplicate, max_reject_cause)
        Result.put (l("That player is not playing"), reject_cause_duplicate)
        Result.put (l("Invalid password"), reject_cause_password)
        Result.put (l("Game has finished"), reject_cause_finished)
        Result.put (l("Access denied"), reject_cause_denied)
        Result.put (l("You are already logged in"), reject_cause_relog)
        Result.put (l("That player is already logged in"), reject_cause_alreadylog)
    end

end -- class JOIN_WINDOW