class FM_SDL_CLIENT_CONNECTION_FACTORY

inherit
    CONNECTION_FACTORY

creation
    make

feature {NONE} -- Creation

    make (new_display: DISPLAY) is
    do
        display := new_display
    end

feature -- Access

    new_connection (host: STRING; port: INTEGER): FM_CLIENT_CONNECTION is
        -- A new connection to `host':`port'
    local
        r: FM_SDL_CLIENT_CONNECTION
    do
        !!r.make (host, port)
        r.set_display (display)
        Result := r
    end

feature {NONE} -- Internal

    display: DISPLAY

end -- class FM_SDL_CLIENT_CONNECTION_FACTORY