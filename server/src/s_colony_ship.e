class S_COLONY_SHIP
    
inherit
    S_SHIP
    redefine creator, make end
    COLONY_SHIP
    undefine
        set_size, set_picture
    redefine creator, make end
    
creation make
        
feature

    creator: S_PLAYER

feature {NONE} -- Creation

    make(p: like creator) is
    do
        Precursor{S_SHIP}(p)
        set_colony_ship_attributes
    end

end -- class S_COLONY_SHIP
