class C_COLONY_SHIP

inherit
    COLONY_SHIP
    redefine make end
    C_SHIP
    redefine make end

creation make

feature {NONE} -- Creation

    make(p: like creator) is
    do
        Precursor{C_SHIP}(p)
        set_colony_ship_attributes
    end

end -- class C_COLONY_SHIP