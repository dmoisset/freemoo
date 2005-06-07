--TODO:
--show destination or orbit center in the title
--handle special cases (monsters, guardian)
--handle commands (colonize planet, download troops)

class FLEET_VIEW
	--ews class view for a FLEET
	 
inherit
	CLIENT
	WINDOW
	rename make as window_make
	redefine redraw, handle_event end
	 
creation
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
        !!fleet_selection.make

        fleet_changed (fleet)
    end
	 
	 
    make_widgets is
    local
	b: BUTTON_IMAGE
	r: RECTANGLE
	bt: BUTTON_TOGGLE_IMAGE
	skip, hpos, vpos: INTEGER
    do
	-- Drag Handle
	r.set_with_size (1, 0, bg_ns_width, bg_top_height)
	!!drag.make (Current, r)
	
	-- Info Label
	r.set_with_size(info_label_x, all_button_y@1, info_label_width, info_label_height)
	!!info_label.make(Current, r, "")
	if fleet.eta /= 0 then
	    info_label.set_text("ETA: " + fleet.eta.to_string + " turns")
	end
	
	-- All
	!!all_button.make(Current, all_button_x, all_button_y@1, all_button_img @ 1, all_button_img @ 1, all_button_img @ 2)
	all_button.set_click_handler (agent select_all)
	
	-- Close
	!!close_button.make (1, 2)
	!!b.make (Current, buttons_x, buttons_y@1, close_button_img.item(1, 1), close_button_img.item(1, 1), close_button_img.item(1, 2))
	b.set_click_handler (agent close)
	close_button.put(b, 1)
	!!b.make (Current, buttons_x, buttons_y@1, close_button_img.item(2, 1), close_button_img.item(2, 1), close_button_img.item(2, 2))
	b.set_click_handler (agent close)
	close_button.put(b, 2)
	
	-- Toggles
	!!toggles.make(0, 8)
	from skip := toggles.lower
	    hpos := 14
	    vpos := 38
	until
	    skip > toggles.upper
	loop
	    !!bt.make(Current, hpos, vpos, cursor @ 1, cursor @ 1, cursor @ 2, cursor @ 2, cursor @ 2, cursor @ 1)
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
	!!scrollbar.make(Current, r, create {SDL_SOLID_IMAGE}.make(0, 0, 30, 30, 250))
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
    
    model_position: POSITIONAL is
    do
	Result := fleet
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

feature {NONE} -- Callbacks

    cancel_trajectory_selection_handler: PROCEDURE[ANY, TUPLE]
	
    close is
    do
        if cancel_trajectory_selection_handler /= Void then
            cancel_trajectory_selection_handler.call ([])
        end
        fleet.changed.disconnect (fleet_changed_handler)
        fleet := Void
        hide
        remove
    end

	toggle_ship_selection(sh: SHIP) is
	do
		if fleet_selection.has(sh) then
			fleet_selection.remove(sh)
			if fleet_selection.is_empty and then cancel_trajectory_selection_handler /= Void then
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
		from
			si := fleet.get_new_iterator
		until
			si.is_off
		loop
			fleet_selection.add(si.item)
			si.next
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
	 
	 
feature {NONE} -- Implementation
	 
	fleet_selection: SET[SHIP]
	 
	ships: ARRAY[SHIP]
	 
	toggles: ARRAY[BUTTON_TOGGLE_IMAGE]
	 
	drag: DRAG_HANDLE
	 
	scrollbar: V_SCROLLBAR
		-- A Bar that Scrolls.
	 
	all_button: BUTTON_IMAGE
	
	info_label: LABEL
	 
	close_button: ARRAY[BUTTON_IMAGE]
	 
feature -- Redefined features
	 
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
	 
	update_toggles is
		-- Show or hide toggle-buttons, and activate or deactivate 
		-- accordingly
	local
		i: INTEGER
		ship: SHIP
		i1, i2: IMAGE
	do
		from i := 0
		until i = 9
		loop
			if i + scrollbar.value * 3 <= ships.upper then
				ship := ships @ (i+scrollbar.value*3)
				i1 := get_ship_pic(fleet.owner.color,
								   ship.creator.color,
								   ship.size,
								   ship.picture, false)
				i2 := get_ship_pic(fleet.owner.color,
								   ship.creator.color,
								   ship.size,
								   ship.picture, true)
				toggles.item(i).set_normal_image(i1)
				toggles.item(i).set_prelight_image(i1)
				toggles.item(i).set_pressed_image(i2)
				toggles.item(i).set_normal_active_image(i2)
				toggles.item(i).set_prelight_active_image(i2)
				toggles.item(i).set_pressed_active_image(i1)
				toggles.item(i).show
				toggles.item(i).set_click_handler(agent toggle_ship_selection(ship))
				toggles.item(i).set_active(fleet_selection.has(ship))
			else
				toggles.item(i).hide
			end
			i := i + 1
		end
	end
	
	
	update_window_size is
		-- Re-dimension window checking ship number in fleet
	local
		r: RECTANGLE
	do
		if fleet.ship_count <= 9 then
			size_index := (fleet.ship_count - 1) // 3 + 2
			scrollbar.hide
			r.set_with_size(0, 0, bg_ns_width, bg_top_height)
			drag.move(r)
			r.set_with_size(buttons_x, buttons_y@size_index, close_button.item(2).width, close_button.item(2).height)
			close_button.item(2).move(r)
			r.set_with_size(location.x, location.y.min(parent.height - bg_tot_height@size_index), bg_ns_width, bg_tot_height@size_index)
			move(r)
		else
			size_index := 1
			scrollbar.show
			r.set_with_size(0, 0, bg_s_width, bg_top_height)
			drag.move(r)
			r.set_with_size(location.x.min(parent.width - bg_s_width), location.y.min(parent.height-bg_tot_height@size_index), bg_s_width, bg_tot_height@size_index)
			move(r)
		end
		
		r.set_with_size(all_button_x, all_button_y@size_index, all_button.width, all_button.height)
		all_button.move(r)
		
		r.set_with_size(info_label_x, all_button_y@size_index, info_label_width, info_label_height)
		info_label.move(r)
		
		close_button.item(size_index.min(2)).show
		close_button.item(size_index.min(2) \\ 2 + 1).hide
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
		!!ships.make(0, -1);
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
		if fleet.eta /= 0 then
		    info_label.set_text("ETA: " + fleet.eta.to_string + " turns")
		else
		    info_label.set_text("")
		end

		if fleet.ship_count = 0 then close end
	end
	 
	 
feature {NONE} -- Once features

	cursor: ARRAY[IMAGE] is
	local
		i: IMAGE_FMI
	once
		!!Result.make(1, 2)
		i := create {IMAGE_FMI}.make_from_file ("client/fleet-view/cursor.fmi")
		Result.put(i, 2)
		Result.put(create {SDL_IMAGE}.make_transparent(i.width, i.height), 1)
	end
	 
	size_index: INTEGER
		-- Used to index image arrays:
		-- 1 if scrollbar is showing
		-- 2, 3 or 4 if not (1, 2, or 3 rows of ships without scrollbar)
	
	background: ARRAY[IMAGE] is
	local
		a: FMA_FRAMESET
	once
		!!Result.make(1, 4)
		Result.put(create{SDL_IMAGE}.make(bg_s_width, bg_tot_height@1), 1)
		Result.put(create{SDL_IMAGE}.make(bg_ns_width, bg_tot_height@2), 2)
		Result.put(create{SDL_IMAGE}.make(bg_ns_width, bg_tot_height@3), 3)
		Result.put(create{SDL_IMAGE}.make(bg_ns_width, bg_tot_height@4), 4)
		
		!!a.make("client/fleet-view/window-top-s.fma")
		a.images.item(1).show(Result @ 1, 0, 0)
		!!a.make("client/fleet-view/window-top-ns.fma")
		a.images.item(1).show(Result @ 2, 0, 0)
		a.images.item(1).show(Result @ 3, 0, 0)
		a.images.item(1).show(Result @ 4, 0, 0)
		  
		!!a.make ("client/fleet-view/window-middle-s.fma")
		a.images.item(1).show(Result @ 1, 2, bg_top_height)
		!!a.make ("client/fleet-view/window-middle-ns.fma")
		a.images.item(1).show(Result @ 2, 2, bg_top_height)
		a.images.item(1).show(Result @ 3, 2, bg_top_height)
		a.images.item(1).show(Result @ 4, 2, bg_top_height)
		  
		!!a.make ("client/fleet-view/window-bottom-s.fma")
		a.images.item(1).show(Result @ 1, 0, bg_bottom_y@1)
		!!a.make ("client/fleet-view/window-bottom-ns.fma")
		a.images.item(1).show(Result @ 2, 0, bg_bottom_y@2)
		a.images.item(1).show(Result @ 3, 0, bg_bottom_y@3)
		a.images.item(1).show(Result @ 4, 0, bg_bottom_y@4)
	end
	 
	ship_pics: ARRAY2[ARRAY2[ARRAY[IMAGE]]] is
		-- Container for ship pics.  Don't access directly; fetch 
		-- images with `get_ship_pic'.
	once
		!!Result.make(fleet.owner.min_color, fleet.owner.max_color,
					  fleet.owner.min_color, fleet.owner.max_color) -- Creator and owner
	end
	
	get_ship_pic(owner, creator, size, pic: INTEGER; highlight: BOOLEAN): IMAGE is
		-- Gets a ship image from `ship_pics', checking first to see if 
		-- it has already been loaded.
	require
		owner.in_range(fleet.owner.min_color, fleet.owner.max_color)
		creator.in_range(fleet.owner.min_color, fleet.owner.max_color)
		size.in_range(1, 6)
		pic.in_range(0, 7)
	local
		a: FMA_FRAMESET
		imgs: ARRAY [IMAGE]
		xoffset, yoffset: INTEGER
		ship_and_cursor: IMAGE_COMPOSITE
	do
		if ship_pics.item(owner, creator) = Void then
			ship_pics.put(create {ARRAY2[ARRAY[IMAGE]]}.make(1, 6, 0, 7), owner, creator)
		end
		if ship_pics.item(owner, creator).item(size, pic) = Void then
			!!imgs.make (1, 2)
			ship_pics.item(owner, creator).put(imgs, size, pic)
			!!a.make("client/fleet-view/ships/ship" + 
			         (creator - fleet.owner.min_color).to_string +
			         size.to_string +
			         pic.to_string +
			         (owner - fleet.owner.min_color).to_string + ".fma")
			xoffset := a.positions.item (1).x
			yoffset := a.positions.item (1).y
			imgs.put(create {IMAGE_OFFSET}.make (a.images @ 1,
			                                     xoffset, yoffset),
			         1)
			create ship_and_cursor.make (cursor.item(1).width, cursor.item(1).height)
			ship_and_cursor.add (a.images.item(1), xoffset, yoffset)
			ship_and_cursor.add (cursor.item(2), 0, 0)
			imgs.put(ship_and_cursor, 2)
		end
		if highlight then
			result := ship_pics.item(owner, creator).item(size, pic).item(2)
		else
			result := ship_pics.item(owner, creator).item(size, pic).item(1)
		end
		
	end
	 
	 
	 --For buttons, image 1 is up, image 2 is down
	 
	 all_button_img: ARRAY[IMAGE] is
	 local
		  i: INTEGER
		  a: FMA_FRAMESET
	 once
		  !!Result.make (1, 2)
		  !!a.make ("client/fleet-view/all-button.fma")
		  from i := 1
		  until i > 2 loop
				Result.put (a.images @ i, i)
				i := i + 1
		  end
	 end
	 
	 close_button_img: ARRAY2[IMAGE] is
	 local
		  j, i: INTEGER
		  a: FMA_FRAMESET
		  file_names: ARRAY[STRING]
	 once
		  !!Result.make (1, 2, 1, 2)
		  file_names := <<"client/fleet-view/close-button-s.fma", "client/fleet-view/close-button-ns.fma">>
		  from j := 1
		  until j > 2
		  loop
				!!a.make (file_names @ j)
				from i := 1
				until i > 2 loop
					 Result.put (a.images @ i, j, i)
					 i := i + 1
				end
				j := j + 1
		  end
	 end
	 
	 --Scrollbar:
	 --1 & 2 is up button, both up and down
	 --3 is the trough
	 --4 & 5 is down button, both up and down
	 
	 scrollbar_img: ARRAY[IMAGE] is
	 local
		  a: FMA_FRAMESET
	 once
		  !!Result.make (1, 5)
		  !!a.make ("client/fleet-view/scrollbar-up.fma")
		  Result.put (a.images @ 1, 1)
		  Result.put (a.images @ 2, 2)
		  !!a.make ("client/fleet-view/scrollbar-trough.fma")
		  Result.put (a.images @ 1, 3)
		  !!a.make ("client/fleet-view/scrollbar-down.fma")
		  Result.put (a.images @ 1, 4)
		  Result.put (a.images @ 2, 5)
	 end
	 
feature {NONE} -- Numeric and Layout Constants
	 
	 bg_top_height: INTEGER is 35
	 
	 bg_ns_width: INTEGER is 196
	 
	 bg_s_width: INTEGER is 217
	 
	 bg_bottom_y: ARRAY[INTEGER] is
	 once
		  !!Result.make(1, 4)
		  Result.put(204, 1)
		  Result.put(90, 2)
		  Result.put(147, 3)
		  Result.put(204, 4)
	 end
	 
	 bg_tot_height: ARRAY[INTEGER] is
	 once
		  !!Result.make(1, 4)
		  Result.put(272, 1)
		  Result.put(158, 2)
		  Result.put(215, 3)
		  Result.put(272, 4)
	 end
	 
	 info_label_x: INTEGER is 80
	 info_label_width: INTEGER is 80
	 info_label_height: INTEGER is 24
	 
	 all_button_x: INTEGER is 16
 
	 all_button_y: ARRAY[INTEGER] is
	 once
		  !!Result.make(1, 4)
		  Result.put(208, 1)
		  Result.put(94, 2)
		  Result.put(151, 3)
		  Result.put(208, 4)
	 end
	 
	 buttons_x: INTEGER is 2
	 
	 buttons_y: ARRAY[INTEGER] is
	 once
		  !!Result.make(1, 4)
		  Result.put(243, 1)
		  Result.put(129, 2)
		  Result.put(185, 3)
		  Result.put(243, 4)
	 end
	 
end -- class FLEET_VIEW

