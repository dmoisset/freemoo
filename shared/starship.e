class STARSHIP
    -- Combat capable ship

inherit
    SHIP
	
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
	
end -- class STARSHIP
