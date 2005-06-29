expanded class PROTOCOL

feature -- Constants

    -- Message types
    msgtype_join: INTEGER is 32
    msgtype_rejoin: INTEGER is 33
    msgtype_setup: INTEGER is 34
    msgtype_start: INTEGER is 35
    msgtype_chat: INTEGER is 36
    msgtype_dialog: INTEGER is 37
    msgtype_turn: INTEGER is 40
    msgtype_fleet: INTEGER is 41
    msgtype_colonize: INTEGER is 42

    msgtype_join_accept: INTEGER is 32
    msgtype_join_reject: INTEGER is 33

    -- Join-Reject possible causes
    reject_cause_duplicate: INTEGER is 0
    reject_cause_unknown: INTEGER is 0
    reject_cause_password: INTEGER is 1
    reject_cause_noslots: INTEGER is 2
    reject_cause_finished: INTEGER is 3
    reject_cause_denied: INTEGER is 4
    reject_cause_relog: INTEGER is 5
    reject_cause_alreadylog: INTEGER is 6

    max_reject_cause: INTEGER is do Result := reject_cause_alreadylog end

end -- class PROTOCOL
