class BUTTON_IMAGE_GROUPABLE
    -- This button allows you to set it's state at will, enabling you
    -- to command it as part of a group of buttons.  Check BUTTON_GROUP for
    -- the class that controls this.

inherit
    BUTTON_IMAGE

create
    make

feature -- Operations

    set_normal is
        do
            set_state (st_normal)
        ensure
            state = st_normal
        end

    set_prelight is
        do
            set_state (st_prelight)
        ensure
            state = st_prelight
        end

    set_pressed is
        do
            set_state (st_pressed)
        ensure
            state = st_pressed
        end

end -- class BUTTON_IMAGE_GROUPABLE
