class C_KNOWLEDGE_BASE

inherit
    KNOWLEDGE_BASE
        redefine make, set_current_tech end
    SUBSCRIBER

creation
    make

feature {NONE} -- Creation

    make is
    do
        create current_tech_changed.make
        Precursor
    end

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
            current_tech := Void
        else
            current_tech := tech_tree.tech (s.last_integer + tech_min.item(category_construction))
        end
        from
            cat := category_construction
        until
            cat > category_force_fields
        loop
            s.get_integer
            set_next_field (tech_tree.field (s.last_integer + field_min.item(category_construction)))
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
            add_tech (tech_tree.tech (s.last_integer + tech_min.item(category_construction)))
            count := count - 1
        end
        current_tech_changed.emit (Current)
    end

feature -- Signals

    current_tech_changed: SIGNAL_1[C_KNOWLEDGE_BASE]

feature -- Operations

    set_current_tech (new_tech: TECHNOLOGY) is
    do
        Precursor (new_tech)
        current_tech_changed.emit (Current)
    end

end -- class C_KNOWLEDGE_BASE
