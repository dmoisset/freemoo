class TURN_SUMMARY_ITEM_PRODUCED

inherit
    TURN_SUMMARY_ITEM

create
    make, unserialize_from

feature {NONE} -- Creation

    make(col_id, product_id: INTEGER; starship_name: STRING) is
    do
        kind := event_finished_production
        colony_id := col_id
        product := product_id
        name := starship_name
    end

feature -- Access

    serialize_on(s: SERIALIZER2) is
    do
        s.add_tuple(<<(kind - event_min).box, colony_id.box, product.box, name>>)
    end

    unserialize_from(u: UNSERIALIZER) is
    do
        kind := event_finished_production
        u.get_integer
        colony_id := u.last_integer
        u.get_integer
        product := u.last_integer
        u.get_string
        name := u.last_string
    end

feature {NONE} -- Representation

    colony_id: INTEGER

    product: INTEGER

    name: STRING

end -- class TURN_SUMMARY_ITEM_PRODUCED
