class EASY_CLIENT
    -- Hack client for forcing an fm_client_connection

inherit
    CLIENT

feature
    easy_set_server(c:FM_CLIENT_CONNECTION) is
    do
        server_ref.set_item (c)
    end

end -- class EASY_CLIENT