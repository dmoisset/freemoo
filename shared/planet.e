class PLANET

inherit
    ORBITING
    MAP_CONSTANTS
	STORABLE
	redefine
		dependents
	end

creation make, make_standard

feature {NONE} -- Creation

    make_standard (star: STAR) is
        -- New planet orbiting `s'
    require
        star /= Void
    do
        orbit_center := star
        size := plsize_min
        climate := climate_min
        mineral := mnrl_min
        gravity := grav_min
        type := type_min
        special := plspecial_nospecial
        orbit := 1
    ensure
        orbit_center = star
    end


    make (star: STAR; newsize, newclimate, newmnrl, newgrav, newtype, newspecial: INTEGER) is
        -- New planet orbiting `s'
    require
        star /= Void
        newsize.in_range (plsize_min, plsize_max)
        newclimate.in_range (climate_min, climate_max)
        newmnrl.in_range (mnrl_min, mnrl_max)
        newgrav.in_range (grav_min, grav_max)
        newtype.in_range (type_min, type_max)
        newspecial.in_range (plspecial_min, plspecial_max)

    do
        orbit_center := star
        size := newsize
        climate := newclimate
        mineral := newmnrl
        gravity := newgrav
        type := newtype
        special := newspecial
        orbit := 1
    ensure
        orbit_center = star
        size = newsize
        climate = newclimate
        mineral = newmnrl
        gravity = newgrav
        type = newtype
        special = newspecial
    end

feature -- Operations

    set_size (newsize: INTEGER) is
    require
        newsize.in_range (plsize_min, plsize_max)
    do
        size := newsize
    ensure
        size = newsize
    end

    set_climate (newclimate: INTEGER) is
    require
        newclimate.in_range (climate_min, climate_max)
    do
        climate := newclimate
    ensure
        climate = newclimate
    end

    set_mineral (newmnrl:INTEGER) is
    require
        newmnrl.in_range (mnrl_min, mnrl_max)
    do
        mineral := newmnrl
    ensure
        mineral = newmnrl
    end

    set_gravity (newgrav: INTEGER) is
    require
        newgrav.in_range (grav_min, grav_max)
    do
        gravity := newgrav
    ensure
        gravity = newgrav
    end

    set_type (newtype: INTEGER) is
    require
        newtype.in_range (type_min, type_max)
    do
        type := newtype
    ensure
        type = newtype
    end

    set_special (newspecial: INTEGER) is
    require
        newspecial.in_range (plspecial_min, plspecial_max)
    do
        special := newspecial
    ensure
        special = newspecial
    end

feature {COLONY}

    set_colony (newcolony: COLONY) is
    do
        colony := newcolony
    ensure
        colony = newcolony
    end

feature -- Access

    colony: COLONY
        -- Established colony, Void if none

    climate: INTEGER

    mineral: INTEGER

    size: INTEGER

    gravity: INTEGER

    type: INTEGER

    special: INTEGER

    orbit: INTEGER

feature -- Operations

    add_ship (sh: SHIP) is
    do
        orbit_center.add_ship (sh)
    end

feature {STAR} -- To keep consistent orbits
    set_orbit (neworbit: INTEGER) is
    require
        neworbit.in_range (1, orbit_center.Max_planets)
    do
        orbit := neworbit
    ensure
        orbit = neworbit
    end

feature -- Saving

	hash_code: INTEGER is
	do
		Result := Current.to_pointer.hash_code
	end

feature {STORAGE} -- Saving

	get_class: STRING is "PLANET"
	
	fields: ITERATOR[TUPLE[STRING, ANY]] is
	do
		Result := (<<["colony", colony],
					 ["climate", climate],
					 ["mineral", mineral],
					 ["size", size],
					 ["gravity", gravity],
					 ["type", type],
					 ["special", special],
					 ["orbit", orbit]
					 ["orbit_center", orbit_center]
					 >>).get_new_iterator
	end

	dependents: ITERATOR[STORABLE] is
	do
		Result := (<<colony, orbit_center>>).get_new_iterator
	end
	
invariant
    orbit_center /= Void
    climate.in_range (climate_min, climate_max)
    mineral.in_range (mnrl_min, mnrl_max)
    size.in_range (plsize_min, plsize_max)
    gravity.in_range (grav_min, grav_max)
    type.in_range (type_min, type_max)
    special.in_range (plspecial_min, plspecial_max)
    orbit.in_range (1, orbit_center.Max_planets)

end -- class PLANET
