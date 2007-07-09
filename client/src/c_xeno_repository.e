class C_XENO_REPOSITORY

inherit
    XENO_REPOSITORY
    redefine race_type, item end
    CLIENT
    SUBSCRIBER

feature

    on_message (msg: STRING; provider: SERVICE_PROVIDER; service: STRING) is
        -- Action when `msg' arrives from `provider''s `service'
    local
        s: UNSERIALIZER
        race_count: INTEGER
        new_race: C_RACE
    do
        create s.start (msg)
        s.get_integer
        race_count := s.last_integer
        from
        variant
            race_count
        until
            race_count = 0
        loop
            s.get_integer
            new_race := item(s.last_integer)
            race_count := race_count - 1
        end
    end

    item(id: INTEGER):  like race_type is
    local
        race_service: STRING
    do
        Result := Precursor(id)
        race_service := "race" + Result.id.to_string
        if server.has(race_service) then
            if not server.subscribed_to(Result, "race" + id.to_string) then
                Result.subscribe(server, race_service)
            end
        end
    end

feature {NONE} -- Anchors

    race_type: C_RACE

end -- class C_XENO_REPOSITORY
