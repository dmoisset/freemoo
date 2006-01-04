deferred class COLONY_VIEW
--
-- Views of different aspects of a colony should inherit this class
--
inherit WINDOW
    rename make as window_make end


feature -- Access

    colony: C_COLONY

feature{NONE} -- Representation

    my_connect_identifier: PROCEDURE[ANY, TUPLE]

feature -- Operations

    update is
    require
        colony /= Void
    deferred
    end

    set_colony(c: C_COLONY) is
    do
        if colony /= Void then
            colony.changed.disconnect(my_connect_identifier)
        end
        colony := c
        colony.changed.connect(my_connect_identifier)
        my_connect_identifier.call([])
    end

feature {NONE} -- Auxiliar

    readjust_positions(imgs: ARRAY[WINDOW]; xpos: INTEGER) is
    local
        factor: DOUBLE
        r: RECTANGLE
        it: ITERATOR[WINDOW]
    do
        if xpos > width then
            factor := width / xpos
            from
                it := imgs.get_new_iterator
            until
                it.is_off
            loop
                r := it.item.location
                r.set_with_size((r.x * factor).floor, r.y, r.width, r.height)
                it.item.move(r)
                it.next
            end
        end
    end

invariant

    my_connect_identifier /= Void

end -- class COLONY_VIEW
