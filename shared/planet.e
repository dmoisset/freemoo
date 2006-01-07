class PLANET

inherit
   ORBITING
   MAP_CONSTANTS

creation make, make_standard

feature {NONE} -- Creation

    make_standard (star: like orbit_center) is
        -- New planet orbiting `s'
    require
        star /= Void
    do
        orbit_center := star
        size := plsize_min
        climate := climate_terran
        mineral := mnrl_min
        gravity := grav_min
        type := type_min
        special := plspecial_nospecial
        orbit := 1
    ensure
        orbit_center = star
    end


    make (star: like orbit_center; newsize, newclimate, newmnrl, newgrav, newtype, newspecial: INTEGER) is
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

feature -- Configuration

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

feature -- Operations

    set_colony (newcolony: like colony) is
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

    name: STRING is
    do
        Result := orbit_center.name + " " + roman @ orbit2planet_number
    end

    is_colonizable: BOOLEAN is
    do
        Result := type = type_planet and colony = Void
    end

feature -- Maximum population

    base_maxpop: INTEGER is
    do
        Result := (planet_maxpop @ 1).item(size, climate)
    end

    subterranean_maxpop_bonus: INTEGER is
        -- Extra population a subterranean race can fit on this planet
    do
        Result := 2 * (size - (plsize_min + 1))
    end

    aquatic_maxpop: INTEGER is
        -- Maximum population an aquatic race can fit on this planet
    local
        aquatic_sense: INTEGER
    do
        if climate = climate_tundra or climate = climate_swamp then
            aquatic_sense := climate_terran
        elseif climate = climate_terran or climate = climate_ocean then
            aquatic_sense := climate_gaia
        else
            aquatic_sense := climate
        end
        Result := (planet_maxpop @ 1).item(size, aquatic_sense)
    end

    tolerant_maxpop: INTEGER is
        -- Maximum population a tolerant race can fit on this planet
    do
        Result := (planet_maxpop @ 2).item(size, climate)
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

feature -- Factory methods

    create_colony(p: PLAYER): like colony is
    require
        p /= Void
        is_colonizable
    do
        create Result.make(Current, p)
    end

feature {NONE} -- Internal for naming

    orbit2planet_number:INTEGER is
    local
        i: INTEGER
    do
        from i := 1 until i > orbit loop
            if orbit_center.planet_at (i) /= Void then Result := Result + 1 end
            i := i + 1
        end
    end

    roman: ARRAY[STRING] is
    once
        Result := << "I", "II", "III", "IV", "V" >>
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
