class C_FLEET
    -- Fleet, client's view
    -- This model can have incomplete information.

inherit
    FLEET
    redefine make end
    MODEL
    SUBSCRIBER

creation
    make

feature {NONE} -- Creation

    make is
    do
        Precursor 
        make_model
    end

end -- class C_FLEET