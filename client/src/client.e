class CLIENT
    -- FreeMOO client

feature -- Operations

    set_server (host: STRING; port: INTEGER; f: CONNECTION_FACTORY) is
        -- Try to connect to `host':`port'; set `server' to new
        -- connection to server, or Void if failed.
    require
        host /= Void
        f /= Void
    local
        tried: BOOLEAN
    do
        if not tried then
            if server = Void then
                server_ref.set_item (f.new_connection (host, port))
            else
                server.make (host, port)
            end
        end
    rescue
        if server /= Void and then not server.is_closed then server.close end
        if not tried then
            tried := True
            retry
        end
    end

feature -- Access

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