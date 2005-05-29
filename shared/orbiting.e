deferred class ORBITING
    -- Objects that can be orbiting a star

feature -- Access

    orbit_center: STAR
        -- Star being orbited by current

    set_orbit_center(s:like orbit_center) is
    do
        orbit_center := s
    ensure
        orbit_center = s
    end

end -- class ORBITING
