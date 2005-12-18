class COLONY_POSSIBLE_CONSTRUCTIONS_VIEW
    -- Shows constructions that can be chosen for building at a colony

inherit
    COLONY_VIEW
    CLIENT

creation
    make

feature {NONE} -- Creation

    make (w: WINDOW; where: RECTANGLE) is
    do
        my_connect_identifier := agent update_possible_constructions
        window_make(w, where)
    end

feature {NONE} -- signal callbacks

    update_possible_constructions is
        -- Update gui
    require
        colony /= Void
    local
        it: ITERATOR[CONSTRUCTION]
        child: ITERATOR[WINDOW]
        label: LABEL
        button: BUTTON_IMAGE
        ypos: INTEGER
        r: RECTANGLE
    do
        -- Remove constructions
        from
            child := children.get_new_iterator
        until
            child.is_off
        loop
            child.item.remove
            child.next
        end
        -- Add constructions again
        from
            ypos := 0
            it := colony.owner.known_constructions.get_new_iterator
        until
            it.is_off
        loop
            if it.item.can_be_built_on(colony) then
                r.set_with_size(0, ypos, location.width, row_height)
                create label.make(Current, r, it.item.name)
                create button.make(Current, 0, ypos, imgs@0, imgs@1, imgs@2)
                button.set_click_handler(agent start_building(it.item))
                ypos := ypos + row_height + 1
            end
            it.next
        end
    end

feature {NONE} -- Callbacks

    start_building(c: CONSTRUCTION) is
    do
        if c.id /= colony.producing then
            server.start_building(colony, c)
        end
    end

feature {NONE} -- Auxiliar functions

    row_height: INTEGER is 14

feature {NONE} -- Images

    imgs: ARRAY[IMAGE] is
    once
        create Result.make(0, 2)
        Result.put(create {IMAGE_FMI}.make_from_file("client/colony-window/construction-button-u.fmi"), 0)
        Result.put(create {IMAGE_FMI}.make_from_file("client/colony-window/construction-button-p.fmi"), 1)
        Result.put(create {IMAGE_FMI}.make_from_file("client/colony-window/construction-button-d.fmi"), 2)
    end

end -- class COLONY_POSSIBLE_CONSTRUCTIONS_VIEW
