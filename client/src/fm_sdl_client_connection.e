class FM_SDL_CLIENT_CONNECTION

inherit
    FM_CLIENT_CONNECTION

creation
    make

feature -- Access

    display: DISPLAY
        -- Display that receives events

feature -- Operations

    set_display (new_display: DISPLAY) is
    do
        display := new_display
    end

end