class SERVER_ACCESS
    -- Access to server

feature -- Access

    server: FM_SERVER is
        -- Server
    once
        !!Result.make
    end

end -- class SERVER_ACCESS