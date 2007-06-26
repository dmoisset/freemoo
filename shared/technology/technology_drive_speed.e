class TECHNOLOGY_DRIVE_SPEED
--
-- A TECHNOLOGY that increases your drive_speed
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
        p.set_drive_speed (p.drive_speed.max (speed))
        p.check_basic_ship_tech
    end

feature {NONE} -- Creation

    make(new_id: INTEGER; drive_speed: REAL) is
    do
        id := new_id
        speed := drive_speed
    ensure
        id = new_id
        speed = drive_speed
    end

feature {NONE} -- Representation

    speed: REAL

end -- class TECHNOLOGY_DRIVE_SPEED
