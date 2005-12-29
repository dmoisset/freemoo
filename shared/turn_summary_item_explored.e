class TURN_SUMMARY_ITEM_EXPLORED

inherit
    TURN_SUMMARY_ITEM

create
    make, unserialize_from

feature {NONE} -- Creation

    make(id: INTEGER) is
    do
        kind := event_explored
        star_id := id
    end

feature -- Access

    serialize_on(s: SERIALIZER2) is
    do
        s.add_tuple(<<(kind - event_min).box, star_id.box>>)
    end

    unserialize_from(u: UNSERIALIZER) is
    do
        kind := event_explored
        u.get_integer
        star_id := u.last_integer
    end

feature {NONE} -- Representation

    star_id: INTEGER

end -- class TURN_SUMMARY_ITEM_EXPLORED
