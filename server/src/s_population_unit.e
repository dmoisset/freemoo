class S_POPULATION_UNIT

inherit
    POPULATION_UNIT
    redefine race, colony end
    STORABLE
    rename
        hash_code as id
    redefine
        dependents, primary_keys
    end

creation
    make

feature -- Redefined features

    race: S_RACE

    colony: S_COLONY

feature {STORAGE} -- Saving

    get_class: STRING is "POPULATION_UNIT"

    fields: ITERATOR[TUPLE[STRING, ANY]] is
    do
        Result := (<<["race", race],
                     ["colony", colony],
                     ["turns_to_assimilation", turns_to_assimilation.box],
                     ["task", (task - task_farming).box]>>).get_new_iterator
    end

    primary_keys: ITERATOR[TUPLE[STRING, ANY]] is
    do
        Result := (<<["id", id.box] >>).get_new_iterator
    end

    dependents: ITERATOR[STORABLE] is
    do
        Result := (<<race, colony>>).get_new_iterator
    end

feature {STORAGE} -- Retrieving	

    set_primary_keys (elems: ITERATOR [TUPLE [STRING, ANY]]) is
    local
        i: REFERENCE [INTEGER]
    do
        from
        until elems.is_off loop
            if elems.item.first.is_equal("id") then
                i ?= elems.item.second
                set_id(i.item)
            end
            elems.next
        end
    end

    make_from_storage (elems: ITERATOR [TUPLE [STRING, ANY]]) is
    local
        i: REFERENCE [INTEGER]
        savedtask: INTEGER
    do
        from
        until elems.is_off loop
            if elems.item.first.is_equal("race") then
                race ?= elems.item.second
            elseif elems.item.first.is_equal("colony") then
                colony ?= elems.item.second
            elseif elems.item.first.is_equal("turns_to_assimilation") then
                i ?= elems.item.second
                turns_to_assimilation := i.item
            elseif elems.item.first.is_equal("task") then
                i ?= elems.item.second
                savedtask := i.item + task_farming
            else
                print ("Bad element inside 'population_unit' tag: " + elems.item.first + "%N")
            end
            elems.next
        end
        task := savedtask
    end

end -- class S_POPULATION_UNIT
