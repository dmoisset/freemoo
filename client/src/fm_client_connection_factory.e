class FM_CLIENT_CONNECTION_FACTORY

inherit
    CONNECTION_FACTORY

feature -- Access

    new_connection (host: STRING; port: INTEGER): FM_CLIENT_CONNECTION is
        -- A new connection to `host':`port'
    do
        !!Result.make (host, port)
    end

end -- class FM_CLIENT_CONNECTION_FACTORY