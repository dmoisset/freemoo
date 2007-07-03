class C_CONSTRUCTION_REPO

inherit
    CONSTRUCTION_REPO
    redefine
        builder
    end
    SUBSCRIBER
    CLIENT

create
    make

feature

    builder: C_CONSTRUCTION_BUILDER

    on_message (msg: STRING; provider: SERVICE_PROVIDER; service: STRING) is
        -- Action when `msg' arrives from `provider''s `service'
    local
        construction_count, product_id: INTEGER
        s: UNSERIALIZER
        starship: C_STARSHIP
    do
        create s.start (msg)
        s.get_integer
        construction_count := s.last_integer
        from
        variant
            construction_count
        until construction_count = 0 loop
            s.get_integer
            product_id := s.last_integer + product_min
            --print("C_CONSTRUCTION_REPO on_message: construction " + product_id.to_string + "%N")
            if product_id > product_max then
                create starship.make(server.player)
                starship.set_id(product_id - product_max)
                s.get_integer
                starship.set_size (s.last_integer)
                starship.unserialize_completely_from(s)
            end
            if not has(product_id) then
                if product_id > product_max then
                    add_starship_design(starship)
                else
                    add_by_id(product_id)
                end
            end
            construction_count := construction_count - 1
        end
    end

end -- class C_CONSTRUCTION_REPO
