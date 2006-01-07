class TURN_SUMMARY_ITEM_EXPLORED

inherit
    TURN_SUMMARY_ITEM
    MAP_CONSTANTS

create
    make, unserialize_from

feature {NONE} -- Creation

    make(star: STAR) is
    do
        kind := event_explored
        star_id := star.id
        star_name := star.name
        star_special := star.special
        planet_special := plspecial_nospecial
        if star_special = stspecial_planetspecial then
                planet_special := star.planet_with_special.special
        end
    end

feature -- Access

    serialize_on(s: SERIALIZER2) is
    do
        s.add_tuple(<<(kind - event_min).box, star_id.box, star_name,
                      (star_special - stspecial_min).box,
                      (planet_special - plspecial_min).box>>)
    end

    unserialize_from(u: UNSERIALIZER) is
    do
        kind := event_explored
        u.get_integer
        star_id := u.last_integer
        u.get_string
        star_name := u.last_string
        u.get_integer
        star_special := u.last_integer + stspecial_min
        u.get_integer
        planet_special := u.last_integer + plspecial_min
    end

feature {NONE} -- Representation

    star_id: INTEGER

    star_special: INTEGER

    planet_special: INTEGER

    star_name: STRING

end -- class TURN_SUMMARY_ITEM_EXPLORED
