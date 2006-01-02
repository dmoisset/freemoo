class TURN_SUMMARY_ITEM_STARVATION

inherit
    TURN_SUMMARY_ITEM

create
    make, unserialize_from

feature {NONE} -- Creation

    make(col_id, food_shortage, industry_shortage: INTEGER) is
    do
        kind := event_starvation
        colony_id := col_id
        food := food_shortage
        industry := industry_shortage
    end

feature -- Access

    serialize_on(s: SERIALIZER2) is
    do
        s.add_tuple(<<(kind - event_min).box, colony_id.box, food.box, industry.box>>)
    end

    unserialize_from(u: UNSERIALIZER) is
    do
        kind := event_starvation
        u.get_integer
        colony_id := u.last_integer
        u.get_integer
        food := u.last_integer
        u.get_integer
        industry := u.last_integer
    end

feature -- Representation

    colony_id: INTEGER

    food: INTEGER

    industry: INTEGER

end -- class TURN_SUMMARY_ITEM_STARVATION
