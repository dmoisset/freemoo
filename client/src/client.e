class CLIENT
    -- FreeMOO client

feature -- Operations

    set_server (host: STRING; port: INTEGER) is
        -- Try to connect to `host':`port'; set `server' to new
        -- connection to server, or Void if failed.
    require
        host /= Void
    local
        s: FM_CLIENT_CONNECTION
        tried: BOOLEAN
    do
        if not tried then
            if server = Void then
                !!s.make (host, port)
                server_ref.set_item (s)
            else
                server.make (host, port)
            end
        end
    rescue
        if not server.is_closed then server.close end
        if not tried then
            tried := True
            retry
        end
    end

feature -- Access

    network_wait: REAL is 0.05
        -- Maximum blocking time when waiting network messages

    server: FM_CLIENT_CONNECTION is
        -- Connection to server, or Void if not connected
    do
        Result := server_ref.item
    end

feature {NONE} -- Internal

    server_ref: MEMO [FM_CLIENT_CONNECTION] is
        -- shared container for server connection
    once
        !!Result
    end

end -- class CLIENT