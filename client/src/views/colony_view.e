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

invariant

    my_connect_identifier /= Void

end -- class COLONY_VIEW
