class C_PLANET

inherit
    PLANET
    redefine colony, orbit_center end

creation make, make_standard

feature

    orbit_center: C_STAR

    colony: C_COLONY

end

