class COLONY_POSSIBLE_CONSTRUCTIONS_VIEW
    -- Shows constructions that can be chosen for building at a colony

inherit
    COLONY_VIEW
    CLIENT

creation
    make

feature {NONE} -- Creation

    make (w: WINDOW; where: RECTANGLE) is
    local
        r, s: RECTANGLE
    do
        my_connect_identifier := agent update_possible_constructions
        window_make(w, where)
        r.set_with_size(167, 2, 10, height - 4)
        s.set_with_size(2, 2, 177, height - 4)
        create list.make(Current, s, r, create {SDL_SOLID_IMAGE}.make(0, 0, 0, 30, 150))
        list.set_button_images(imgs@0, imgs@1, imgs@2)
        list.set_up_images(up_imgs@0, up_imgs@1, up_imgs@2)
        list.set_down_images(down_imgs@0, down_imgs@1, down_imgs@2)
        list.set_click_handler(agent start_building)
        list.set_on_enter_handler(agent show_description)
        list.set_on_exit_handler(agent show_nothing)
        r.set_with_size(190, 10, width - 190, 140)
        create description_label.make(Current, r, "")
        description_label.set_wordwrap(True)
    end

feature {NONE} -- signal callbacks

    update_possible_constructions is
        -- Update gui
    require
        colony /= Void
    local
        tuple: TUPLE[ARRAY[CONSTRUCTION], ARRAY[STRING]]
    do
        tuple := get_constructions
        list.from_collections(tuple.first, tuple.second)
    end

feature {NONE} -- Callbacks

    start_building(c: CONSTRUCTION) is
    do
        if c.id /= colony.producing.id and not colony.has_bought then
            server.start_building(colony, c)
        end
    end

    show_description(c: CONSTRUCTION) is
    do
        description_label.set_text(c.description)
    end

    show_nothing(c: CONSTRUCTION) is
    do
        description_label.set_text("")
    end

feature {NONE} -- Auxiliar

    get_constructions: TUPLE[ARRAY[CONSTRUCTION], ARRAY[STRING]] is
    require
        colony /= Void
    local
        constructions: ARRAY[CONSTRUCTION]
        names: ARRAY[STRING]
        it: ITERATOR[CONSTRUCTION]
    do
        create constructions.make(1, 0)
        create names.make(1, 0)
        from
            it := colony.owner.known_constructions.get_new_iterator
        until
            it.is_off
        loop
            if it.item.can_be_built_on(colony) then
                constructions.add_last(it.item)
                names.add_last(it.item.name)
            end
            it.next
        end
        Result := [constructions, names]
    end

    get_names(constructions: HASHED_DICTIONARY[CONSTRUCTION, INTEGER]): ARRAY[STRING] is
    local
        it: ITERATOR[CONSTRUCTION]
    do
        create Result.with_capacity(constructions.count, 0)
        from
            it := constructions.get_new_iterator_on_items
        until
            it.is_off
        loop
            Result.add_last(it.item.name)
            it.next
        end
    end

feature {NONE} -- Widgets

    list: SCROLLED_LIST[CONSTRUCTION]

    description_label: MULTILINE_LABEL

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

    up_imgs: ARRAY[IMAGE] is
    local
        a: FMA_FRAMESET
    once
        create Result.make(0, 2)
        create a.make("client/turnsum/up.fma")
        Result.put(a.images @ 1, 0)
        Result.put(a.images @ 1, 1)
        Result.put(a.images @ 2, 2)
    end

    down_imgs: ARRAY[IMAGE] is
    local
        a: FMA_FRAMESET
    once
        create Result.make(0, 2)
        create a.make("client/turnsum/down.fma")
        Result.put(a.images @ 1, 0)
        Result.put(a.images @ 1, 1)
        Result.put(a.images @ 2, 2)
    end

end -- class COLONY_POSSIBLE_CONSTRUCTIONS_VIEW
