class PLANET

inherit
    ORBITING
    MAP_CONSTANTS

creation make

feature {NONE} -- Creation

    make (star: STAR; newsize: INTEGER; newclimate: INTEGER;
          newmnrl:INTEGER; newgrav: INTEGER; newtype: INTEGER;
          newspecial: INTEGER) is
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
        neworbit.in_range (1, 5)
    do
        orbit := neworbit
    ensure
        orbit = neworbit
    end

invariant
    orbit_center /= Void
    climate.in_range (climate_min, climate_max)
    mineral.in_range (mnrl_min, mnrl_max)
    size.in_range (plsize_min, plsize_max)
    gravity.in_range (grav_min, grav_max)
    type.in_range (type_min, type_max)
    special.in_range (plspecial_min, plspecial_max)
    orbit.in_range (1, 5)

end -- class PLANET