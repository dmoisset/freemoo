class COLONY_POPULATORS_VIEW
    -- Shows a colony's populators in three rows, and allows to rearrange them

inherit
    COLONY_VIEW
    CLIENT

creation
    make

feature {NONE} -- Creation

    make(w: WINDOW; where: RECTANGLE) is
    do
        my_connect_identifier := agent update_populators
        window_make(w, where)
    end

feature {NONE} -- Signal callbacks

    update_populators is
        -- Update gui
    require
        colony /= Void
    local
        x: ARRAY[INTEGER]
        new_children: ARRAY[ARRAY[WINDOW]]
        button: BUTTON_IMAGE
        raceicon: IMAGE
        child: ITERATOR[WINDOW]
        pop: ITERATOR[POPULATION_UNIT]
        task: INTEGER
    do
        -- Remove populators
        from
            child := children.get_new_iterator
        until
            child.is_off
        loop
            child.item.remove
            child.next
        end
        create x.make(0, 3)
        create new_children.make(0, 2)
        new_children.put(create {ARRAY[WINDOW]}.make(1, 0), 0)
        new_children.put(create {ARRAY[WINDOW]}.make(1, 0), 1)
        new_children.put(create {ARRAY[WINDOW]}.make(1, 0), 2)
        -- Add populators again
        from
            pop := colony.populators.get_new_iterator_on_items
        until
            pop.is_off
        loop
            task := pop.item.task - pop.item.task_farming
            raceicon := get_raceicon(pop.item.race.picture, pop.item.task -
                                     pop.item.task_farming + raceicon_farmer)
            create button.make(Current, x@ task, icon_height * task,
                   raceicon, raceicon, raceicon)
            button.set_click_handler(agent switch_task(pop.item))
            x.put(x @ task + icon_width, task)
            new_children.item(task).add_last(button)
            -- To Do: Consider hostages!
            pop.next
        end
        readjust_positions(new_children @ 0, x @ 0)
        readjust_positions(new_children @ 1, x @ 1)
        readjust_positions(new_children @ 2, x @ 2)
    end

feature {NONE} -- Callbacks

    switch_task(pop: POPULATION_UNIT) is
    local
        bag: HASHED_SET[POPULATION_UNIT]
    do
        create bag.make
        bag.add(pop)
        if pop.able_worker and (pop.task = pop.task_farming or
           (pop.task = pop.task_science and not pop.able_farmer)) then
            -- Do command locally for quick user feedback
            colony.set_task(bag, pop.task_industry)
            -- And request the server's command
            server.set_task(colony, bag, pop.task_industry)
        elseif pop.able_scientist and (pop.task = pop.task_industry or
           (pop.task = pop.task_farming and not pop.able_worker)) then
            colony.set_task(bag, pop.task_science)
            server.set_task(colony, bag, pop.task_science)
        elseif pop.able_farmer and pop.task /= pop.task_farming then
            colony.set_task(bag, pop.task_farming)
            server.set_task(colony, bag, pop.task_farming)
        end
        update_populators
    end

feature {NONE} -- Implementation constants

    icon_height: INTEGER is 33

    icon_width: INTEGER is 30

feature {NONE} -- Images

    raceicon_farmer, raceicon_worker, raceicon_scientist, raceicon_spy,
    raceicon_hostage: INTEGER is unique

    raceicon_pics: ARRAY2[IMAGE] is
        -- Container for race icons (li'l farmers, workers, scientists).
        -- Don't access directly; fetch images with `get_raceicon'.
    once
        !!Result.make(0, 14, raceicon_farmer, raceicon_hostage)
    end

    get_raceicon(picture, role: INTEGER): IMAGE is
        -- Gets a ship image from `raceicon_pics', checking first to see if 
        -- it has already been loaded.
    require
        picture.in_range(0, 14)
        role.in_range(raceicon_farmer, raceicon_hostage)
    local
        a: FMA_FRAMESET
    do
        if raceicon_pics.item(picture, role) = Void then
            !!a.make("client/colony-view/populators/pop" + picture.to_string
               + (role - raceicon_farmer).to_string + ".fma")
            raceicon_pics.put(a.images @ 1, picture, role)
        end
        Result := raceicon_pics.item(picture, role)
    end

end -- class COLONY_POPULATORS_VIEW
