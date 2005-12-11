class COLONY_PRODUCTION_VIEW
    -- Shows a colony's production, with detailed description and everything

inherit
    WINDOW
--    redefine handle_event end
    CLIENT

creation
    make

feature -- Representation

   colony: C_COLONY

feature -- Redefined features

    update_production is
        -- Update gui
    require
        colony /= Void
    local
        item, x, prod_missing: INTEGER
        image: WINDOW_IMAGE
        icon: IMAGE
        child: ITERATOR[WINDOW]
    do
        -- Remove production
        from
            child := children.get_new_iterator
        until
            child.is_off
        loop
            child.item.remove
            child.next
        end
        -- Add production again
        from
            item := 0
        until
            item > 3
        loop
            x := 0
            from
                prod_missing := accumulator(item).total.floor
            until
                prod_missing = 0
            loop
                if prod_missing >= 10 then
                    icon := prod_icon.item(item, 1)
                    prod_missing := prod_missing - 10
                else
                    icon := prod_icon.item(item, 0)
                    prod_missing := prod_missing - 1
                end
                create image.make(Current, x, item * row_height, icon)
                x := x + icon.width
            end
            item := item + 1
        end
    end

    set_colony(c: C_COLONY) is
    do
        if colony /= Void then
            colony.changed.disconnect(agent update_production)
        end
        colony := c
        colony.changed.connect(agent update_production)
        update_production
    end

feature {NONE} -- Auxiliar functions

    row_height: INTEGER is 33

    accumulator(item: INTEGER): EXPLAINED_ACCUMULATOR[REAL] is
    require
        colony /= Void
    do
        inspect
            item
        when 0 then
            Result := colony.money
        when 1 then
            Result := colony.farming
        when 2 then
            Result := colony.industry
        when 3 then
            Result := colony.science
        end
    end

feature {NONE} -- Images

    prod_icon: ARRAY2[IMAGE] is
    local
        a: FMA_FRAMESET
        i, j: INTEGER
    once
        create Result.make(0,3,0,1)
        from i := 0 until i > 3 loop
            from j := 0 until j > 1 loop
                !!a.make("client/colony-view/production/prod" + i.to_string
                         + j.to_string + ".fma")
                Result.put(a.images @ 1, i, j)
                j := j + 1
            end
            i := i + 1
        end
    end

end -- class COLONY_PRODUCTION_VIEW
