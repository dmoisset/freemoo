class ONGOING_CONSTRUCTION
--
-- A construction that never finishes being built (trade_goods, housing)
-- These constructions need a hand from COLONY, as they're special
-- cases; so you won't find much functionality here, go grep COLONY.
--

inherit
    CONSTRUCTION
    redefine
        can_be_built_on, build, take_down, is_buyable
    end
    GETTEXT

creation
    make

feature -- Defined features

    can_be_built_on(c: like colony_type): BOOLEAN is
    do
        Result := True
    end

    build, take_down(c: like colony_type) is
        -- You should never build an ongoing construction
    do
    ensure
        False
    end

    is_buyable: BOOLEAN is
    do
    end

end -- ONGOING_CONSTRUCTION
