class ORBITING_FLEETS_VIEW
    -- Galaxy view of fleets orbiting a star, for using inside the star-view window
inherit
    WINDOW
        rename make as window_make
        redefine redraw, handle_event, remove end

creation make    


feature {NONE} -- Creation

    make (w: WINDOW; where: RECTANGLE; s: C_STAR; g: C_GALAXY) is
        -- build widget as view of `s'
    require
        w /= Void
        s /= Void
        g /= Void
    local
        r: RECTANGLE
    do
        window_make(w, where)
        star := s
        -- Register on galaxy
        galaxy_changed_handler := agent galaxy_changed
        galaxy := g
        galaxy.fleets_change.connect(galaxy_changed_handler)
        -- Fleet hotspots
        !!fleet_hotspots.make
        on_model_change
    end

feature -- Controls

    set_fleet_click_handler (p: PROCEDURE[ANY, TUPLE[C_FLEET]]) is
    do
        fleet_click_handler := p
    end

feature {NONE} -- Callbacks

    fleet_click_handler: PROCEDURE[ANY, TUPLE[C_FLEET]]


feature {NONE} -- Signal handlers

    galaxy_changed_handler: PROCEDURE [ANY, TUPLE[C_GALAXY]]

    galaxy_changed (g: C_GALAXY) is
    require
        g = galaxy
    do
        on_model_change
    end


    on_model_change is
        -- Update gui
    require
        star /= Void
        galaxy /= Void
    local
        fleet: ITERATOR[C_FLEET]
        r: RECTANGLE
    do
        -- Redraw the cache on next redraw
        dirty := True
        -- Generate hotspots
        fleet_hotspots.clear
        from
            fleet := galaxy.get_new_iterator_on_fleets
            r.set_with_size(0, 0, fleet_pic_width, fleet_pic_height)
        until fleet.is_off
        loop
            if fleet.item.orbit_center = star and fleet.item.destination = Void then
                fleet_hotspots.add (r, fleet.item.id)
                r.translate(fleet_pic_width + fleet_pic_margin, 0)
            end
            fleet.next
        end
    end

feature -- Redefined features

    remove is
    do
        galaxy.fleets_change.disconnect(galaxy_changed_handler)
        Precursor
    end

    redraw(r: RECTANGLE) is
    local
        i: INTEGER
        fleet_id: ITERATOR[INTEGER]
    do
        if dirty then
            dirty := False
            !!cache.make_transparent (width, height)
    -- Fleets
            from
                fleet_id := fleet_hotspots.get_new_iterator_on_keys
            until fleet_id.is_off loop
                fleets.item(galaxy.fleet_with_id(fleet_id.item).owner.color).show(cache, i, 0)
                i := i + (fleet_pic_width + fleet_pic_margin)
                fleet_id.next
            end
        end
        show_image(cache, 0, 0, r)
        Precursor(r)
    end

    handle_event(event: EVENT) is
    local
        b: EVENT_MOUSE_BUTTON
        it: ITERATOR[RECTANGLE]
    do
        Precursor(event)
        if not event.handled then
            b ?= event
            if b /= Void then
                event.set_handled
                if b.button = 1 and not b.state then
                    from it := fleet_hotspots.get_new_iterator_on_items
                    until it.is_off
                    loop
                        if (it.item.has(b.x, b.y)) then
                            if fleet_click_handler /= Void then
                                fleet_click_handler.call([galaxy.fleet_with_id (fleet_hotspots.key_at(it.item))])
                            end
                        end
                        it.next
                    end
                end
            end
        end
    end

feature -- Once data

    fleets: ARRAY[IMAGE] is
    local
        i: INTEGER
        a: FMA_FRAMESET
    once
        !!Result.make(0, 7)
        from i := 0
        until i > 7 loop
            !!a.make("client/star-view/fleet" + i.to_string + ".fma")
            Result.put(a.images @ 1, i)
            i := i + 1
        end
    end

feature {NONE} -- Internal

    galaxy: C_GALAXY
    
    star: C_STAR

    fleet_hotspots: DICTIONARY[RECTANGLE, INTEGER]

    cache: SDL_IMAGE

    dirty: BOOLEAN

feature {NONE} -- Internal constants

    fleet_pic_margin: INTEGER is 5
    fleet_pic_width: INTEGER is 17
    fleet_pic_height: INTEGER is 14

end -- class ORBITING_FLEETS_VIEW
