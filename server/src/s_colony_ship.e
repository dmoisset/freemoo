class S_COLONY_SHIP
    
inherit
    S_SHIP
    redefine creator end
    COLONY_SHIP
    redefine creator end
    
creation make
        
feature
    
    creator: S_PLAYER
    
end -- class S_COLONY_SHIP
