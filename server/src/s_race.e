class S_RACE

inherit
RACE
    redefine set_attribute end
        SERVICE
    redefine subscription_message end
    STORABLE
    rename
        hash_code as id
    redefine
        primary_keys
    end

creation make

feature

    set_attribute(attr: STRING) is
    do
        Precursor(attr)
        update_clients
    end

feature

    update_clients is
    do
        -- Check to avoid updates on initialization
        if registry /= Void then
            send_message ("race" + id.to_string, subscription_message ("race" + id.to_string))
        end
    end

    subscription_message (service_id: STRING): STRING is
    require
        service_id.is_equal("race" + id.to_string)
    local
        s: SERIALIZER2
    do
        !!s.make
        serialize_on(s)
        Result := s.serialized_form
    end


feature {STORAGE} -- Saving

    get_class: STRING is "RACE"

    fields: ITERATOR[TUPLE[STRING, ANY]] is
    local
        a: ARRAY[TUPLE[STRING, ANY]]
    do
        create a.make(1, 0)
        a.add_last(["name", name])
        a.add_last(["homeworld_name", homeworld_name])
        a.add_last(["picture", picture.box])
        a.add_last(["population_growth", population_growth.box])
        a.add_last(["farming_bonus", farming_bonus.box])
        a.add_last(["industry_bonus", industry_bonus.box])
        a.add_last(["science_bonus", science_bonus.box])
        a.add_last(["money_bonus", money_bonus.box])
        a.add_last(["ship_defense_bonus", ship_defense_bonus.box])
        a.add_last(["ship_attack_bonus", ship_attack_bonus.box])
        a.add_last(["ground_combat_bonus", ground_combat_bonus.box])
        a.add_last(["spying_bonus", spying_bonus.box])
        a.add_last(["government", (government - government_feudal).box])
        a.add_last(["homeworld_size", homeworld_size.box])
        a.add_last(["homeworld_gravity", homeworld_gravity.box])
        a.add_last(["homeworld_richness", homeworld_richness.box])
        a.add_last(["ancient_artifacts", ancient_artifacts.box])
        a.add_last(["aquatic", aquatic.box])
        a.add_last(["subterranean", subterranean.box])
        a.add_last(["cybernetic", cybernetic.box])
        a.add_last(["lithovore", lithovore.box])
        a.add_last(["repulsive", repulsive.box])
        a.add_last(["charismatic", charismatic.box])
        a.add_last(["uncreative", uncreative.box])
        a.add_last(["creative", creative.box])
        a.add_last(["tolerant", tolerant.box])
        a.add_last(["fantastic_trader", fantastic_trader.box])
        a.add_last(["telepathic", telepathic.box])
        a.add_last(["lucky", lucky.box])
        a.add_last(["omniscient", omniscient.box])
        a.add_last(["stealthy", stealthy.box])
        a.add_last(["transdimensional", transdimensional.box])
        a.add_last(["warlord", warlord.box])
        Result := a.get_new_iterator
    end

    primary_keys: ITERATOR[TUPLE[STRING, ANY]] is
    do
        Result := (<<["id", id.box] >>).get_new_iterator
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
                id := i.item
            end
            elems.next
        end
    end

feature {STORAGE} -- Retrieving

    make_from_storage (elems: ITERATOR [TUPLE [STRING, ANY]]) is
    local
        i: REFERENCE [INTEGER]
        b: REFERENCE [BOOLEAN]
    do
        from
        until elems.is_off loop
            if elems.item.first.is_equal("name") then
                name ?= elems.item.second
            elseif elems.item.first.is_equal("homeworld_name") then
                homeworld_name ?= elems.item.second
            elseif elems.item.first.is_equal("picture") then
                i ?= elems.item.second
                picture := i.item
            elseif elems.item.first.is_equal("population_growth") then
                i ?= elems.item.second
                population_growth := i.item
            elseif elems.item.first.is_equal("farming_bonus") then
                i ?= elems.item.second
                farming_bonus := i.item
            elseif elems.item.first.is_equal("industry_bonus") then
                i ?= elems.item.second
                industry_bonus := i.item
            elseif elems.item.first.is_equal("science_bonus") then
                i ?= elems.item.second
                science_bonus := i.item
            elseif elems.item.first.is_equal("money_bonus") then
                i ?= elems.item.second
                money_bonus := i.item
            elseif elems.item.first.is_equal("ship_defense_bonus") then
                i ?= elems.item.second
                ship_defense_bonus := i.item
            elseif elems.item.first.is_equal("ship_attack_bonus") then
                i ?= elems.item.second
                ship_attack_bonus := i.item
            elseif elems.item.first.is_equal("ground_combat_bonus") then
                i ?= elems.item.second
                ground_combat_bonus := i.item
            elseif elems.item.first.is_equal("spying_bonus") then
                i ?= elems.item.second
                spying_bonus := i.item
            elseif elems.item.first.is_equal("government") then
                i ?= elems.item.second
                government := i.item + government_feudal
            elseif elems.item.first.is_equal("homeworld_size") then
                i ?= elems.item.second
                homeworld_size := i.item
            elseif elems.item.first.is_equal("homeworld_gravity") then
                i ?= elems.item.second
                homeworld_gravity := i.item
            elseif elems.item.first.is_equal("ancient_artifacts") then
                b ?= elems.item.second
                ancient_artifacts := b.item
            elseif elems.item.first.is_equal("aquatic") then
                b ?= elems.item.second
                aquatic := b.item
            elseif elems.item.first.is_equal("subterranean") then
                b ?= elems.item.second
                subterranean := b.item
            elseif elems.item.first.is_equal("cybernetic") then
                b ?= elems.item.second
                cybernetic := b.item
            elseif elems.item.first.is_equal("lithovore") then
                b ?= elems.item.second
                lithovore := b.item
            elseif elems.item.first.is_equal("repulsive") then
                b ?= elems.item.second
                repulsive := b.item
            elseif elems.item.first.is_equal("charismatic") then
                b ?= elems.item.second
                charismatic := b.item
            elseif elems.item.first.is_equal("uncreative") then
                b ?= elems.item.second
                uncreative := b.item
            elseif elems.item.first.is_equal("creative") then
                b ?= elems.item.second
                creative := b.item
            elseif elems.item.first.is_equal("tolerant") then
                b ?= elems.item.second
                tolerant := b.item
            elseif elems.item.first.is_equal("fantastic_trader") then
                b ?= elems.item.second
                fantastic_trader := b.item
            elseif elems.item.first.is_equal("telepathic") then
                b ?= elems.item.second
                telepathic := b.item
            elseif elems.item.first.is_equal("lucky") then
                b ?= elems.item.second
                telepathic := b.item
            elseif elems.item.first.is_equal("omniscient") then
                b ?= elems.item.second
                omniscient := b.item
            elseif elems.item.first.is_equal("stealthy") then
                b ?= elems.item.second
                stealthy := b.item
            elseif elems.item.first.is_equal("transdimensional") then
                b ?= elems.item.second
                transdimensional := b.item
            end
            elems.next
        end
    end

end -- class S_RACE
