deferred class FM_DIALOG
    -- FreeMOO dialog variant.
    -- each FreeMOO dialog is associated to a single player

inherit
    DIALOG

feature -- Access

    player: PLAYER is
        -- Associated player
    deferred
    end

end -- class FM_DIALOG