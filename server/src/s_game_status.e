class S_GAME_STATUS
    -- Public status of the server

inherit
    GAME_STATUS
    redefine
        fill_slot, start, finish, next_date
    end
    SERVICE
    redefine subscription_message end

creation
    make_with_options

feature -- Redefined features

    subscription_message (service_id: STRING): STRING is
    local
        s: SERIALIZER
    do
        s.serialize ("ibbiiibbbi", <<open_slots, finished, started,
                     galaxy_size, galaxy_age, start_tech_level,
                     tactical_combat, random_events, antaran_attacks,
                     date>>)
        Result := s.serialized_form
    end

feature -- Access

    id: STRING is "game_status"

feature -- Operations

    fill_slot is
    do
        Precursor
        update_clients
    end

    start is
    do
        Precursor
        update_clients
    end

    finish is
    do
        Precursor
        update_clients
    end

    next_date is
    do
        Precursor
        update_clients
    end

    update_clients is
    do
        send_message (id, subscription_message (id))
    end

end -- class S_GAME_STATUS