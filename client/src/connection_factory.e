deferred class CONNECTION_FACTORY

feature -- Access

    new_connection (host: STRING; port: INTEGER): FM_CLIENT_CONNECTION is
        -- A new connection to `host':`port'
    deferred
    end

end -- deferred class CONNECTION_FACTORY