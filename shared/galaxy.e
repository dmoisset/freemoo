class GALAXY

creation make

feature {NONE} -- Creation

    make is
    do
        !!stars.with_capacity (0, 1)
        !!fleets.with_capacity (0,1)
    end

feature -- Access

    stars: ARRAY [STAR]
        -- stars in the map, by id

    fleets: ARRAY [FLEET]
        -- All the active fleets.  Need's handling methods like new_fleet,
        -- maybe even a new class FLEET_LIST

feature -- Operations

feature {MAP_GENERATOR} -- Generation
    set_stars (starlist:ARRAY[STAR]) is
    require
        starlist /= Void
    do
        stars := starlist
    end

invariant
    stars /= Void
    fleets /= Void

end -- class GALAXY