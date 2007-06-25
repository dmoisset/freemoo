class TURN_SUMMARY_ITEM_RESEARCH

inherit
    TURN_SUMMARY_ITEM
    TECHNOLOGY_CONSTANTS

create
    make, unserialize_from

feature {NONE} -- Creation

    make(tech: TECHNOLOGY) is
    do
        kind := event_researched
        tech_id := tech.id - tech_min.item (category_construction)
    end

feature -- Access

    serialize_on(s: SERIALIZER2) is
    do
        s.add_tuple(<<(kind - event_min).box, tech_id.box>>)
    end

    unserialize_from(u: UNSERIALIZER) is
    do
        kind := event_researched
        u.get_integer
        tech_id := u.last_integer + tech_min.item (category_construction)
    end

feature {NONE} -- Representation

    tech_id: INTEGER

end -- class TURN_SUMMARY_ITEM_RESEARCH
