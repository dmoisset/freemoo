class S_COLONY_SHIP
    
inherit
    S_SHIP
    redefine creator, make, get_class end
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

feature -- Redefined features

    get_class: STRING is "COLONY_SHIP"

end -- class S_COLONY_SHIP
