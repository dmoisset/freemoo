--TODO:
--auto shrink with small fleets
--color the scrollbar trough
--implement scrollbar
--implement selection
--implement the "all" button
--show destination or orbit center in the title
--handle special cases (monsters, guardian)


class FLEET_VIEW
	--ews class view for a FLEET
	
inherit
	VIEW[C_FLEET]
	WINDOW
		rename make as window_make
		redefine redraw, handle_event end
		
creation
	make
	
feature {NONE} -- Creation
	
	make (w: WINDOW; where: RECTANGLE; new_model: C_FLEET) is
			-- build widget as view of `new_model'
		local
			r: RECTANGLE
		do
			window_make(w, where)
			set_model (new_model)

			r.set_with_size (1, 0, bg_ns_width, bg_top_height)
			!!drag.make (Current, r)

			make_buttons

			r.set_with_size(0, 0, width, height)
			!!ships.make(Current, r)

			!!fleet_selection.make
			
			-- Scrollbar
			r.set_with_size(191, 42, 15, 158)
			!!scrollbar.make(Current, r, create {SDL_SOLID_IMAGE}.make(0, 0, 30, 30, 250))
			scrollbar.set_first_button_images(create {SDL_SOLID_IMAGE}.make(0, 0, 0, 0, 0), scrollbar_img @ 1, scrollbar_img @ 2)
			scrollbar.set_second_button_images(create {SDL_SOLID_IMAGE}.make(0, 0, 0, 0, 0), scrollbar_img @ 4, scrollbar_img @ 5)
			scrollbar.set_limits(0, model.ship_count, 0)
			scrollbar.set_increments(1, 4)
			r.set_with_size(2, 17, 11, 51)
			scrollbar.set_trough(r)
			scrollbar.set_value(0)
			scrollbar.set_change_handler(agent redraw_ships)

			on_model_change
		end

	make_buttons is
		local
			b: BUTTON_IMAGE
			r: RECTANGLE
			bt: BUTTON_TOGGLE_IMAGE
			skip, hpos, vpos: INTEGER
		do
			-- All
			!!all_button.make (Current, all_button_x, all_button_y, all_button_img @ 1, all_button_img @ 1, all_button_img @ 2)
			all_button.set_click_handler (agent select_all)

			-- Close
			!!close_button.make (1, 2)
			!!b.make (Current, buttons_x, buttons_y, close_button_img.item(1, 1), close_button_img.item(1, 1), close_button_img.item(1, 2))
			b.set_click_handler (agent close)
			close_button.put(b, 1)
			!!b.make (Current, buttons_x, buttons_y, close_button_img.item(2, 1), close_button_img.item(2, 1), close_button_img.item(2, 2))
			b.set_click_handler (agent close)
			close_button.put(b, 2)

			-- Toggles
			!!toggles.make(0, 8)
			from skip := toggles.lower
				hpos := 15
				vpos := 40
			until
				skip > toggles.upper
			loop
				!!bt.make(Current, hpos, vpos, cursor @ 1, cursor @ 1, cursor @ 2 cursor @ 2, cursor @ 2, cursor @ 1)
				toggles.put(bt, skip)
				bt.set_active(true)
				hpos := hpos + 57
				if hpos > 150 then
					hpos := 15
					vpos := vpos + 56
				end
				skip := skip + 1
			end
		end
	
feature {NONE} -- Callbacks

	close is
		do
			remove
		end
	
	select_all is
		do
		end

	redraw_ships is
		local
			it: ITERATOR[SHIP]
			vpos, hpos, skip: INTEGER
			wi: WINDOW_IMAGE
		do
			from it := model.get_new_iterator
				skip := 0
			until
				skip = scrollbar.value
			loop
				skip := skip + 1
				it.next
			end
			from
				hpos := 28
				vpos := 53
				skip := 0
			until it.is_off or skip = 9
			loop
				!!wi.make (ships, hpos, vpos, get_ship_pic(model.owner.color, it.item.creator.color, it.item.size, it.item.picture))
				hpos := hpos + 57
				if hpos > 150 then
					hpos := 28
					vpos := vpos + 57
				end
				toggles.item(skip).set_active(fleet_selection.has(it.item))
				skip := skip + 1
				it.next
			end
			
			from
			until
				skip = 9
			loop
				toggles.item(skip).set_active(false)
				skip := skip + 1
			end
		end
	
feature {NONE} -- Implementation

	fleet_selection: SET[SHIP]
	
	toggles: ARRAY[BUTTON_TOGGLE_IMAGE]
	
	drag: DRAG_HANDLE

	scrollbar: V_SCROLLBAR
			-- A Bar that Scrolls.
	
	all_button: BUTTON_IMAGE
	
	close_button: ARRAY[BUTTON_IMAGE]
	
feature -- Redefined features
	
	redraw (r: RECTANGLE) is
		do
			show_image (background @ size_index, 0, 0, r)
			Precursor (r)
		end
	
	handle_event (event: EVENT) is
		do
			Precursor (event)
			if not event.handled then
			end
		end
	
feature {NONE}
	--Hack - just here for today.

	ships: WINDOW

	cursor: ARRAY[IMAGE] is
		local
			a: FMA_FRAMESET
		once
			!!Result.make(1, 2)
			!!a.make("client/fleet-view/cursor.fma")
			Result.put(a.images @ 1, 2)
			Result.put(create {SDL_IMAGE}.make_transparent((Result @ 2).width, (Result @ 2).height), 1)
		end
	
feature {MODEL}
	
	on_model_change is
			--Update gui
		local
			w: ITERATOR[WINDOW]
		do
			from w := ships.children.get_new_iterator
			until
				w.is_off
			loop
				w.item.remove
				w.next
			end

			update_window
			redraw_ships
		end

	update_window is
			-- Re-dimension window checking ship number in fleet
		local
			r: RECTANGLE
			i: INTEGER
		do
			if model.ship_count <= 9 then
				size_index := 2
				scrollbar.hide
				r.set_with_size(location.x, location.y, bg_ns_width, 272)
				move(r)
				r.set_with_size(0, 0, bg_ns_width, bg_top_height)
				drag.move(r)
			else
				size_index := 1
				scrollbar.show
  				r.set_with_size(location.x.min(parent.location.width - 217), location.y, 217, 272)
				move(r)
				r.set_with_size(0, 0, bg_s_width, bg_top_height)
				drag.move(r)
			end
			from i := 0
			until i = 9
			loop
				if i < model.ship_count then
					toggles.item(i).show
				else
					toggles.item(i).hide
				end
				i := i + 1
			end
			close_button.item(size_index).show
			close_button.item(size_index \\ 2 + 1).hide
		end
	
feature {NONE} -- Once features

	--For each window_* array, the first image has scrollbar, the second doesn't

	size_index: INTEGER
			-- Used to index image arrays:
			-- 1 if scrollbar is showing
			-- 2 if not.
	
	background: ARRAY[SDL_IMAGE] is
		local
			img: SDL_IMAGE
			a: FMA_FRAMESET
		once
			!!Result.make(1, 2)
			Result.put(create{SDL_IMAGE}.make(bg_s_width, 272), 1)
			!!a.make("client/fleet-view/window-top-s.fma")
			img ?= a.images @ 1
			img.blit_fast(Result @ 1, 0, 0)
			!!a.make ("client/fleet-view/window-middle-s.fma")
			img ?= a.images @ 1
			img.blit_fast(Result @ 1, 2, bg_top_height)
			!!a.make ("client/fleet-view/window-bottom-s.fma")
			img ?= a.images @ 1
			img.blit_fast(Result @ 1, 0, 204)
			
			Result.put(create{SDL_IMAGE}.make(bg_ns_width, 272), 2)
			!!a.make("client/fleet-view/window-top-ns.fma")
			img ?= a.images @ 1
			img.blit_fast(Result @ 2, 0, 0)
			!!a.make ("client/fleet-view/window-middle-ns.fma")
			img ?= a.images @ 1
			img.blit_fast(Result @ 2, 2, bg_top_height)
			!!a.make ("client/fleet-view/window-bottom-ns.fma")
			img ?= a.images @ 1
			img.blit_fast(Result @ 2, 0, 204)
		end
	
	ship_pics: ARRAY2[ARRAY2[IMAGE]] is
			-- Container for ship pics.  Don't access directly; fetch 
			-- images with `get_ship_pic'.
		once
			!!Result.make(model.owner.min_color, model.owner.max_color,
							  model.owner.min_color, model.owner.max_color) -- Creator and owner
		end

	get_ship_pic(owner, creator, size, pic: INTEGER): IMAGE is
			-- Gets a ship image from `ship_pics', checking first to see if 
			-- it has already been loaded.
		require
			owner.in_range(model.owner.min_color, model.owner.max_color)
			creator.in_range(model.owner.min_color, model.owner.max_color)
			size.in_range(1, 6)
			pic.in_range(0, 7)
		local			
			a: FMA_FRAMESET
		do
			if ship_pics.item(owner, creator) = Void then
				ship_pics.put(create {ARRAY2[IMAGE]}.make(1, 6, 0, 7), owner, creator)
			end
			if ship_pics.item(owner, creator).item(size, pic) = Void then
				!!a.make("client/fleet-view/ships/ship" + (creator - model.owner.min_color).to_string + size.to_string + pic.to_string + (owner - model.owner.min_color).to_string + ".fma")
				ship_pics.item(owner, creator).put(a.images @ 1, size, pic)
			end
			result := ship_pics.item(owner, creator).item(size, pic)
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

feature {NONE} -- Constants

	bg_top_height: INTEGER is 35

	bg_ns_width: INTEGER is 196

	bg_s_width: INTEGER is 217
	
	all_button_x: INTEGER is  16

	all_button_y: INTEGER is 208

	buttons_x: INTEGER is 2

	buttons_y: INTEGER is 235
	
end -- class FLEET_VIEW


