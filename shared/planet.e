class PLANET

inherit
    ORBITING

creation make

feature {NONE} -- Creation

    make (s: STAR) is
        -- New lpanet orbiting `s'
    require
        s /= Void
    do
        orbit_center := s
    ensure
        orbit_center = s
    end

feature -- Access

    orbit_center: STAR
        -- Star being orbited by current

    colony: COLONY
        -- Established colony, Void if none

feature -- Operations

    add_ship (item: SHIP) is
    do
        orbit_center.add_ship (sh)
    end

invariant
    orbit_center /= Void

end -- class PLANET