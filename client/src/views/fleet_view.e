--TODO:
--handle special cases (monsters, guardian)

class FLEET_VIEW
    -- Main window display of FLEETs

inherit
    CLIENT
    WINDOW
        rename
            make as window_make
        redefine
            redraw, handle_event, remove
        end
    SHIP_PICS

create
    make

feature {NONE} -- Representation

    fleet: C_FLEET

feature {NONE} -- Creation

    make (w: WINDOW; where: RECTANGLE; f: C_FLEET) is
        -- build widget as view of `f'
    local
        r: RECTANGLE
    do
        window_make(w, where)

        fleet_changed_handler := agent fleet_changed
        fleet := f
        fleet.changed.connect (fleet_changed_handler)

        make_widgets
        create fleet_selection.make

        fleet_changed (fleet)
        select_all
    end

    make_button (images: ARRAY2 [IMAGE]; action: PROCEDURE [ANY, TUPLE]): ARRAY [BUTTON_IMAGE] is
        -- Generic creation for action buttons (Colonize, close, etc.)
    local
        b: BUTTON_IMAGE
    do
        create Result.make (1, 2)
        create b.make (Current, buttons_x, buttons_y @ 1,
                       images.item(1, 1), images.item(1, 1), images.item(1, 2))
        b.set_click_handler (action)
        Result.put(b, 1)
        create b.make (Current, buttons_x, buttons_y @ 1,
                       images.item(2, 1), images.item(2, 1), images.item(2, 2))
        b.set_click_handler (action)
        Result.put(b, 2)
    end

    make_widgets is
    local
        r: RECTANGLE
        bt: BUTTON_TOGGLE_IMAGE
        skip, hpos, vpos: INTEGER
    do
        r.set_with_size (1, 0, bg_tot_width@1, bg_top_height)
        -- Title Label
        if fleet.owner /= Void and then
           fleet.owner.race /= Void and then
           fleet.owner.race.name /= Void then
            create title_label.make(Current, r, fleet.owner.race.name + " Fleet")
        else
            create title_label.make(Current, r, "Fleet")
        end
        title_label.set_v_alignment(0.65)

        -- Drag Handle
        create drag.make (Current, r)

        -- Info Label
        r.set_with_size(info_label_x, all_button_y@1, info_label_width,
                        info_label_height)
        create info_label.make(Current, r, "")
        if fleet.eta /= 0 then
            info_label.set_text("ETA: " + fleet.eta.to_string + " turns")
        end

        -- All
        create all_button.make(Current, all_button_x, all_button_y@1,
                               all_button_img @ 1, all_button_img @ 1,
                               all_button_img @ 2)
        all_button.set_click_handler (agent select_all)

        -- Action buttons
        close_button := make_button (close_button_img, agent remove)
        engage_button := make_button (engage_button_img, agent engage_button_handler)
        colonize_button := make_button (colonize_button_img, agent colonize_button_handler)

        -- Toggles
        create toggles.make(0, 8)
        from skip := toggles.lower
            hpos := 14
            vpos := 38
        until
            skip > toggles.upper
        loop
            create bt.make(Current, hpos, vpos, cursor @ 1, cursor @ 1, cursor @ 2,
                      cursor @ 2, cursor @ 2, cursor @ 1)
            toggles.put(bt, skip)
            bt.set_active(true)
            hpos := hpos + 58
            if hpos > 150 then
                hpos := 14
                vpos := vpos + 56
            end
            skip := skip + 1
        end

        -- Scrollbar
        r.set_with_size(191, 42, 15, 158)
        create scrollbar.make(Current, r, create {SDL_SOLID_IMAGE}.make(0, 0, 30, 30, 250))
        scrollbar.set_first_button_images(create {SDL_SOLID_IMAGE}.make(0, 0, 0, 0, 0), scrollbar_img @ 1, scrollbar_img @ 2)
        scrollbar.set_second_button_images(create {SDL_SOLID_IMAGE}.make(0, 0, 0, 0, 0), scrollbar_img @ 4, scrollbar_img @ 5)
        scrollbar.set_limits(0, (fleet.ship_count - 1) // 3 + 1, 0)
        scrollbar.set_increments(1, 3)
        r.set_with_size(2, 28, 9, 100)
        scrollbar.set_trough(r)
        scrollbar.set_value(0)
        scrollbar.set_change_handler(agent scrollbar_handler)
    end

feature {GALAXY_VIEW} -- Auxiliary for commanding

    some_ships_selected: BOOLEAN is
    do
        Result := not fleet_selection.is_empty
    end

    selection_is_in_range(dest: C_STAR): BOOLEAN is
    do
        Result := fleet.owner.is_in_range(dest, fleet, fleet_selection)
    end

    model_position: POSITIONAL is
    do
        Result := fleet
    end

    model_orbit_center: C_STAR is
    do
        Result := fleet.orbit_center
    end

    set_cancel_trajectory_selection_callback (p: PROCEDURE[ANY, TUPLE]) is
    do
        cancel_trajectory_selection_handler := p
    end

    send_selection_to(s: STAR) is
    do
        if fleet.owner = server.player and fleet.can_receive_orders then
            server.move_fleet(fleet, s, fleet_selection)
        end
    end

    set_info_eta(dest: STAR) is
    require
        dest /= Void
    do
        info_label.set_text("ETA: " + fleet.eta_at(dest).to_string + " turns")
    end

    set_info_distance(dest: STAR) is
    require
        dest /= Void
    do
        info_label.set_text(fleet.distance_to(dest).ceiling.to_string + " Parsecs")
    end

    set_info_black_hole is
    do
        info_label.set_text("Blackhole blocks!")
    end

feature {NONE} -- Callbacks

    toggle_ship_selection(sh: SHIP) is
    do
        if fleet_selection.has(sh) then
            fleet_selection.remove(sh)
            if fleet_selection.is_empty and then
               cancel_trajectory_selection_handler /= Void then
                cancel_trajectory_selection_handler.call([])
            end
        else
            fleet_selection.add(sh)
        end
    end

    select_all is
    local
        si: ITERATOR[SHIP]
    do
        if fleet.can_receive_orders and fleet.owner = server.player then
            from
                si := fleet.get_new_iterator
            until
                si.is_off
            loop
                fleet_selection.add(si.item)
                si.next
            end
        end
        update_toggles
        all_button.set_click_handler(agent select_none)
    end

    select_none is
    do
        fleet_selection.clear
        if cancel_trajectory_selection_handler /= Void then
            cancel_trajectory_selection_handler.call([])
        end
        update_toggles
        all_button.set_click_handler(agent select_all)
    end

    scrollbar_handler(value: INTEGER) is
    do
        update_toggles
    end

    colonize_button_handler is
    do
        server.colonize (fleet)
    end

    engage_button_handler is
    do
        server.engage (fleet)
    end

feature {NONE} -- Implementation

    cancel_trajectory_selection_handler: PROCEDURE[ANY, TUPLE]

    fleet_selection: HASHED_SET[SHIP]

    ships: ARRAY[SHIP]

    toggles: ARRAY[BUTTON_TOGGLE_IMAGE]

    drag: DRAG_HANDLE

    title_label: LABEL

    scrollbar: V_SCROLLBAR
        -- A Bar that Scrolls.

    all_button: BUTTON_IMAGE

    info_label: LABEL

    close_button: ARRAY[BUTTON_IMAGE]

    engage_button: ARRAY[BUTTON_IMAGE]

    colonize_button: ARRAY[BUTTON_IMAGE]

feature -- Redefined features

    remove is
    do
        if cancel_trajectory_selection_handler /= Void then
            cancel_trajectory_selection_handler.call ([])
        end
        fleet.changed.disconnect (fleet_changed_handler)
        fleet := Void
        hide
        Precursor
    end

    redraw (r: RECTANGLE) is
    do
        show_image (background @ size_index, 0, 0, r)
        Precursor (r)
    end

    handle_event (event: EVENT) is
    local
        m: EVENT_MOUSE_MOVE
        b: EVENT_MOUSE_BUTTON
        n: EVENT_MOUSE_NOTIFY
    do
        Precursor (event)
        if not event.handled then
            m ?= event
            b ?= event
            n ?= event
            if m /= Void or b /= Void or n /= Void then
                event.set_handled
            end
        end
    end

feature {NONE} -- Internal features

    set_info_default is
    -- Show some random information in the little information box
    do
        if fleet.eta /= 0 then
            info_label.set_text("ETA: " + fleet.eta.to_string + " turns")
        else
            info_label.set_text("")
        end
    end

    set_info_shipname(s: SHIP) is
    require
        s /= Void
    local
        st: STARSHIP
        cs: COLONY_SHIP
    do
        cs ?= s
        if cs /= Void then
            if cs.can_colonize then
                info_label.set_text("Colony ship")
            else
                info_label.set_text("Colonizing...")
            end
        else
            st ?= s
            if st /= Void and then st.name /= Void then
                info_label.set_text(st.name)
            end
        end
    end

    update_toggles is
        -- Show or hide toggle-buttons, and activate or deactivate 
        -- accordingly
    local
        i: INTEGER
        ship: SHIP
        i1, i2: IMAGE
        commandable_fleet: BOOLEAN
    do
        commandable_fleet := fleet.owner = server.player and then fleet.can_receive_orders
        from i := 0
        until i = 9
        loop
            if i + scrollbar.value * 3 <= ships.upper then
                ship := ships @ (i+scrollbar.value*3)
                i1 := get_ship_pic(fleet.owner.color,
                                   ship.creator.color,
                                   ship.size,
                                   ship.picture, false)
                toggles.item(i).set_normal_image(i1)
                toggles.item(i).set_prelight_image(i1)
                toggles.item(i).set_pressed_active_image(i1)
                if commandable_fleet then
                    i2 := get_ship_pic(fleet.owner.color,
                                       ship.creator.color,
                                       ship.size,
                                       ship.picture, true)
                    toggles.item(i).set_pressed_image(i2)
                    toggles.item(i).set_normal_active_image(i2)
                    toggles.item(i).set_prelight_active_image(i2)
                    toggles.item(i).set_click_handler(agent toggle_ship_selection(ship))
                else
                    toggles.item(i).set_pressed_image(i1)
                    toggles.item(i).set_normal_active_image(i1)
                    toggles.item(i).set_prelight_active_image(i1)
                    toggles.item(i).set_click_handler(Void)
                end
                toggles.item(i).show
                toggles.item(i).set_on_enter_handler(agent set_info_shipname(ship))
                toggles.item(i).set_on_exit_handler(agent set_info_default)
                toggles.item(i).set_active(fleet_selection.has(ship))
            else
                toggles.item(i).hide
            end
            i := i + 1
        end
    end

    button_offset: INTEGER
        -- Offset of the next button to be shown
    
    update_button (b: ARRAY [BUTTON]; condition: BOOLEAN) is
        -- Show or hide `b' according to condition.
    local
        r: RECTANGLE
        button_idx: INTEGER
    do
        button_idx := (size_index.max(3) \\ 2) + 1
        if condition then
            r.set_with_size(buttons_x, buttons_y @ size_index + button_offset,
                            b.item(button_idx).width,
                            b.item(button_idx).height)
            b.item(button_idx).move(r)
            button_offset := button_offset + b.item(button_idx).height
            b.item(button_idx).show
            b.item((button_idx \\ 2) + 1).hide
        else
            b.item(1).hide
            b.item(2).hide
        end
    end

    update_window_size is
        -- Re-dimension window checking ship number in fleet
    local
        r: RECTANGLE
        window_h, button_idx: INTEGER
    do
        size_index := ((fleet.ship_count - 1) // 3 + 1).min(4)
        button_idx := (size_index.max(3) \\ 2) + 1

        if size_index < 4 then
            scrollbar.hide
        else
            scrollbar.show
        end

        r.set_with_size(0, 0, bg_tot_width@size_index, bg_top_height)
        drag.move(r)
        title_label.move(r)

        -- Add relevant buttons
        button_offset := 0 
        update_button (engage_button,
           fleet.can_engage and then
           fleet.orbit_center /= Void and then
           fleet.destination = Void and then
           fleet.has_target_at (server.galaxy))
        update_button (colonize_button,
           fleet.can_colonize and then
           fleet.orbit_center /= Void and then
           fleet.orbit_center.has_colonizable_planet and then
           fleet.destination = Void)
        update_button (close_button, True)
        
        -- Other widgets
        r.set_with_size(all_button_x, all_button_y@size_index,
                        all_button.width, all_button.height)
        all_button.move(r)

        r.set_with_size(info_label_x, all_button_y@size_index,
                        info_label_width, info_label_height)
        info_label.move(r)

        window_h := bg_tot_height @ size_index + button_offset
        r.set_with_size(location.x.min(parent.width - bg_tot_width @ size_index),
                        location.y.min(parent.height - window_h),
                        bg_tot_width @ size_index, window_h)
        move(r)
    end


feature {NONE} -- Signal Handler

    fleet_changed_handler: PROCEDURE [ANY, TUPLE [C_FLEET]]

    fleet_changed (f: C_FLEET) is
    require
        f = fleet
    do
        on_model_change
    end

    on_model_change is
        --Update gui
    local
        si: ITERATOR[SHIP]
    do
        create ships.make(0, -1);
        from
            si := fleet.get_new_iterator
        until
            si.is_off
        loop
            ships.add_last(si.item)
            si.next
        end

        scrollbar.set_value(0);
        scrollbar.set_limits(0, (ships.count - 1) // 3 + 1, ((ships.count - 1) // 3 + 1).min(3));

        update_window_size
        select_none
        update_toggles
        set_info_default

        if fleet.ship_count = 0 then remove end
    end


feature {NONE} -- Once features

    size_index: INTEGER
        -- Used to index image arrays:
        -- 1 if scrollbar is showing
        -- 2, 3 or 4 if not (1, 2, or 3 rows of ships without scrollbar)

    background: ARRAY[IMAGE] is
    local
        a: FMA_FRAMESET
        i: INTEGER
    once
        create Result.make(1, 4)
        from i := 1 until i > 4 loop
            Result.put(create{SDL_IMAGE}.make(bg_tot_width@i,
                                              bg_tot_height@i), i)
            i := i + 1
        end

        create a.make("client/fleet-view/window-top-ns.fma")
        a.images.item(1).show(Result @ 1, 0, 0)
        a.images.item(1).show(Result @ 2, 0, 0)
        a.images.item(1).show(Result @ 3, 0, 0)
        create a.make("client/fleet-view/window-top-s.fma")
        a.images.item(1).show(Result @ 4, 0, 0)

        create a.make ("client/fleet-view/window-middle-ns.fma")
        a.images.item(1).show(Result @ 1, 2, bg_top_height)
        a.images.item(1).show(Result @ 2, 2, bg_top_height)
        a.images.item(1).show(Result @ 3, 2, bg_top_height)
        create a.make ("client/fleet-view/window-middle-s.fma")
        a.images.item(1).show(Result @ 4, 2, bg_top_height)

        create a.make ("client/fleet-view/window-bottom-ns.fma")
        a.images.item(1).show(Result @ 1, 0, bg_bottom_y@1)
        a.images.item(1).show(Result @ 2, 0, bg_bottom_y@2)
        a.images.item(1).show(Result @ 3, 0, bg_bottom_y@3)
        create a.make ("client/fleet-view/window-bottom-s.fma")
        a.images.item(1).show(Result @ 4, 0, bg_bottom_y@4)
    end

--For buttons, image 1 is up, image 2 is down

    all_button_img: ARRAY[IMAGE] is
    local
        a: FMA_FRAMESET
    once
        create a.make ("client/fleet-view/all-button.fma")
        Result := a.images.slice (1, 2)
    end

    action_button_img (fn1, fn2: STRING): ARRAY2 [IMAGE] is
    local
        j, i: INTEGER
        a: FMA_FRAMESET
        file_names: ARRAY[STRING]
    do
        create Result.make (1, 2, 1, 2)
        file_names := <<fn1, fn2>>
        from j := 1 until j > 2 loop
            create a.make (file_names @ j)
            from i := 1 until i > 2 loop
                Result.put (a.images @ i, j, i)
                i := i + 1
            end
            j := j + 1
        end
    end

    close_button_img: ARRAY2[IMAGE] is
    once
        Result := action_button_img (
            "client/fleet-view/close-button-s.fma",
            "client/fleet-view/close-button-ns.fma")
    end

    engage_button_img: ARRAY2[IMAGE] is
    once
        Result := action_button_img (
            "client/fleet-view/engage-button-s.fma",
            "client/fleet-view/engage-button-ns.fma")
    end

    colonize_button_img: ARRAY2[IMAGE] is
    once
        Result := action_button_img (
            "client/fleet-view/colonize-button-s.fma",
            "client/fleet-view/colonize-button-ns.fma")
    end

    --Scrollbar:
    --1 & 2 is up button, both up and down
    --3 is the trough
    --4 & 5 is down button, both up and down

    scrollbar_img: ARRAY[IMAGE] is
    local
        a: FMA_FRAMESET
    once
        create Result.make (1, 5)
        create a.make ("client/fleet-view/scrollbar-up.fma")
        Result.put (a.images @ 1, 1)
        Result.put (a.images @ 2, 2)
        create a.make ("client/fleet-view/scrollbar-trough.fma")
        Result.put (a.images @ 1, 3)
        create a.make ("client/fleet-view/scrollbar-down.fma")
        Result.put (a.images @ 1, 4)
        Result.put (a.images @ 2, 5)
    end

feature {NONE} -- Numeric and Layout Constants

    bg_top_height: INTEGER is 35

    bg_bottom_y: ARRAY[INTEGER] is
    once
        Result := << 90, 147, 204, 204 >>
    end

    bg_tot_height: ARRAY[INTEGER] is
    once
        Result := <<127, 184, 241, 241>>
    end

    bg_tot_width: ARRAY[INTEGER] is
    once
        Result := << 196, 196, 196, 217 >>
    end

    info_label_x: INTEGER is 72
    info_label_width: INTEGER is 110
    info_label_height: INTEGER is 24

    all_button_x: INTEGER is 16

    all_button_y: ARRAY[INTEGER] is
    once
        Result := << 94, 151, 208, 208 >>
    end

    buttons_x: INTEGER is 2

    buttons_y: ARRAY[INTEGER] is
    once
        Result := << 129, 185, 243, 243 >>
    end

end -- class FLEET_VIEW
