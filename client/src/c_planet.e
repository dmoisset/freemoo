class C_PLANET

inherit 
    PLANET
    redefine colony end

creation make, make_standard

feature
    colony: C_COLONY

end

