class SERVER

inherit
    SERVER_ACCESS

creation
    make

feature {NONE} -- Creation

    make is do server.run end

end -- class SERVER