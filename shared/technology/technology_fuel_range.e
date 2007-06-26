class TECHNOLOGY_FUEL_RANGE
--
-- A TECHNOLOGY that increases your fuel_range
--

inherit
    TECHNOLOGY
        redefine research end

creation
    make

feature

    research(p: PLAYER) is
    do
        Precursor (p)
        p.set_fuel_range (p.fuel_range.max (range))
        p.check_basic_ship_tech
    end

feature {NONE} -- Creation

    make(new_id: INTEGER; fuel_range: REAL) is
    do
        id := new_id
        range := fuel_range
    ensure
        id = new_id
        range = fuel_range
    end

feature {NONE} -- Representation

    range: REAL

end -- class TECHNOLOGY_FUEL_RANGE
