class STARSHIP
    -- Combat capable ship

inherit
    SHIP
    redefine make end

creation
    make

feature -- Access

    name: STRING

feature -- Operations

    set_name(new_name: STRING) is
    do
        name := new_name
    ensure
        name = new_name
    end

feature {NONE} -- Creation

    make(p: like creator) is
    do
        Precursor(p)
        set_starship_attributes
    end

    set_starship_attributes is
    do
        ship_type := 2
    end

end -- class STARSHIP
