class FLEET
-- Group of SHIPs moving together
	
inherit
    UNIQUE_ID
    POSITIONAL
    ORBITING
	
creation
    make
	
feature -- Access
	
    owner: PLAYER
        -- Player that controls Current
	
    is_in_orbit: BOOLEAN is
        -- Is in orbit around a star?
    do
        Result := orbit_center /= Void
    ensure
        Result = (orbit_center /= Void)
    end
	
    destination: like orbit_center
        -- Star where to which the fleet is traveling, or Void if none
    
    current_speed: REAL
		-- Represents distance traveled by Current in one turn.
		-- Current_speed should be recalculated each time ships join 
		-- or leave the fleet, calling recalculate_current_speed.  
		-- It represents the fleet's base traveling speed, and is the 
		-- minimum of the fleet's ships' traveling speeds, plus modifiers
    
    eta: INTEGER
        -- Estimated time of arrival when traveling, 0 when not
		-- Should be recalculated each time the fleet receives new 
		-- orders calling recalculate_eta, and each time a turn 
		-- passes (substracting one)
	
    is_stopped: BOOLEAN is
        -- is stopped?
    do
        Result := destination = Void
    ensure
        Result = (destination = Void)
    end
	
    ship_count: INTEGER is
        -- Number of ships in fleet
    do
        Result := ships.count
    end
	
    has_ship (sid: INTEGER): BOOLEAN is
        -- fleet has a ship with id `sid'?
    do
        Result := ships.has (sid)
    end
    
    ship (sid: INTEGER): like ship_type is
        -- Ship in this fleet with id `sid'
    require
        has_ship (sid)
    do
        Result := ships @ sid
    end
    
    get_new_iterator: ITERATOR[like ship_type] is
        -- Returns an iterator on the fleet's ships
    do
        Result:= ships.get_new_iterator_on_items
    end
	
    splitted_fleet: like Current
	
    
    eta_at(dest: POSITIONAL):INTEGER is
		-- Estimate a time of arrival at `dest'
    require
		dest /= Void
		current_speed > 0
    do
		Result := ((Current |-| dest) / current_speed).ceiling
    end
    
    can_receive_orders: BOOLEAN is
		-- Can this fleet receive new orders at the moment?
		-- In the future it should check owner's modifiers, advances 
		-- at destination, and other stuff.
    do
		Result := is_in_orbit
    end
    
feature -- Operations
	
    add_ship (s: like ship_type) is
        -- Add `s' to fleet
    do
        ships.put (s, s.id)
		scanner_range := 0
		recalculate_current_speed
    ensure
        has_ship (s.id)
    end
    
    remove_ship (s: like ship_type) is
        -- Remove `s' from fleet
    do
        ships.remove(s.id)
		scanner_range := 0
		recalculate_current_speed
    ensure
        not has_ship(s.id)
    end
	
    clear_ships is
    do
        ships.clear
        scanner_range := 0
    end
	
    join (other: like Current) is
        -- Join up with another fleet
    require
        other /= Void
    do
        other.ships.do_all (agent ships.put (?, ?))
        other.clear_ships
        scanner_range := 0
		recalculate_current_speed
    ensure
        ship_count >= old ship_count
        ship_count <= old ship_count + old other.ship_count
    end
	
    split(sh: ITERATOR [like ship_type]) is
        -- Removes ships in`sh' from current fleet, and returns a 
        -- fleet with those ships, and the same
        -- `owner', `orbit_center', `destination' and `eta' as Current.
    require
        sh /= Void
        -- sh.for_all (agent has_ship (?.id))
    do
        !!splitted_fleet.make
        splitted_fleet.move_to (Current)
        splitted_fleet.set_destination(destination)
        splitted_fleet.set_eta(eta)
        splitted_fleet.set_owner(owner)
        if orbit_center /= Void then
            splitted_fleet.enter_orbit (orbit_center)
        end
        from until sh.is_off loop
            remove_ship(sh.item)
            splitted_fleet.add_ship(sh.item)
            sh.next
        end
		scanner_range := 0
		recalculate_current_speed
		splitted_fleet.recalculate_current_speed
    ensure
        same_fleet: (splitted_fleet.eta = eta) and 
                    (splitted_fleet.owner = owner) and
                    (splitted_fleet.destination = destination) and 
                    (splitted_fleet.orbit_center = orbit_center)
        ship_conservation: splitted_fleet.ship_count + ship_count = old ship_count
    end
	
    enter_orbit (star: like orbit_center) is
        -- Put fleet in orbit around `star'
    require
        star /= Void
        not is_in_orbit
    do
        move_to (star)
        orbit_center := star
        eta := 0
        destination := Void
        orbit_center.add_fleet (Current)
    ensure
        is_in_orbit and orbit_center = star
    end
	
    leave_orbit is
        -- Abandon orbit
    require
        is_in_orbit
    do
        orbit_center.remove_fleet (Current)
        orbit_center := Void
    ensure
        not is_in_orbit
    end
	
    move is
    do
        -- Departure
        if is_in_orbit and not is_stopped then
			recalculate_eta
            leave_orbit
        end
        -- Travel
		check not is_stopped = not is_in_orbit end
        if destination /= Void then
			-- This should evolve in to a more complex calculation
			-- Involving modifiers like nebulae, or enemies' 
			-- warp dissipators
            move_towards (destination, current_speed)
			eta := (eta - 1).max(0)
        end
        -- Arrival
        if eta = 0 and not is_stopped then
            enter_orbit (destination)
            owner.add_to_known_list (orbit_center)
            owner.add_to_visited_list (orbit_center)
        end
    end
	
feature -- Operations
	
    copy_from (f: like Current) is
		-- Copies all information from `f', except ship list
    do
		owner := f.owner
		destination := f.destination
		eta := f.eta
		id := f.id
		orbit_center := f.orbit_center
		x := f.x
		y := f.y
		scanner_range := 0
    end
	
    set_eta (e: INTEGER) is
    require
        valid_eta: e >= 0
    do
        eta := e
    ensure
        eta = e
    end
    
    recalculate_eta is
    require
		not is_stopped
		current_speed > 0
    do
		eta := eta_at(destination)
    ensure
		valid_eta: eta >= 0
    end
    
    recalculate_current_speed is
		-- Very dumb for now.
    do
		current_speed := 1.0
    ensure
		current_speed > 0
    end
    
    set_destination (d: like destination) is
    do
        destination := d
        if destination = orbit_center then destination := Void end
    ensure
        d /= orbit_center implies destination = d
    end
	
    set_owner (o: like owner) is
    do
        owner := o
		scanner_range := 0
    ensure
        owner = o
    end
	
feature {GALAXY} -- Scanning
	
    scan(alienfleet: like Current; alienship: like ship_type): BOOLEAN is
		-- Returns true if this fleet picks up `alienship' with it's 
		-- scanners.  `alienship' is part of `alienfleet'
    require
		alienfleet.has_ship(alienship.id)
    do
		if scanner_range = 0 then
			recalculate_scanner_range
		end
		
		if owner.race.omniscient then
			Result := true
		else
			if Current |-| alienfleet < scanner_range + alienship.size - alienship.ship_size_frigate then
				Result := true
			end
		end
    end
	
feature {NONE} -- Auxiliary for scanning
	
    scanner_range: INTEGER
		-- Scanner range considering all our fleet's modifiers.  
		-- Should be reset to 0 after any modification (joining, 
		-- splitting, leader assignment, etc.).
    
    recalculate_scanner_range is
		-- Recalculates `scanner_range' considering all our modifiers.
		-- Quite dumb for now...
    do
		scanner_range := 2
    end
	
feature {NONE} -- Creation
	
    make is
    do
        make_unique_id
        !!ships.make
		current_speed := 1.0
    end
	
feature {FLEET} -- Representation
	
    ships: DICTIONARY [like ship_type, INTEGER]
        -- Ships, indexed by id
    
feature -- Anchors
    
    ship_type: SHIP    
    
invariant
    orbiting_really_here: is_in_orbit implies distance_to (orbit_center) = 0
    nonnegative_speed: current_speed >= 0
    nonnegative_eta: eta >= 0
    positive_speed: current_speed > 0
end -- class FLEET
