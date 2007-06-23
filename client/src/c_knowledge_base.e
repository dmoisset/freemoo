class C_KNOWLEDGE_BASE

inherit
    KNOWLEDGE_BASE
    SUBSCRIBER

creation
    make

feature

    on_message (msg: STRING; provider: SERVICE_PROVIDER; service: STRING) is
        -- Action when `msg' arrives from `provider''s `service'
    local
        s: UNSERIALIZER
        cat, count: INTEGER
    do
        create s.start (msg)
        s.get_integer
        if s.last_integer = -1 then
            current_research := Void
        else
            current_research := tech_tree.tech (s.last_integer)
        end
        from
            cat := category_construction
        until
            cat > category_force_fields
        loop
            s.get_integer
            set_next_field (tech_tree.field (s.last_integer))
            cat := cat + 1
        end
        s.get_integer
        known_technologies.clear
        from
            count := s.last_integer
        until
            count = 0
        loop
            s.get_integer
            add_tech (tech_tree.tech (s.last_integer))
            count := count - 1
        end
    end
end -- class C_KNOWLEDGE_BASE
