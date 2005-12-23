class ONGOING_CONSTRUCTION
--
-- A construction that never finishes being built (trade_goods, housing)
-- These constructions need a hand from COLONY, as they're special
-- cases; so you won't find much functionality here, go grep COLONY.
--

inherit
    CONSTRUCTION
    redefine
        can_be_built_on, build, take_down, name
    end
    GETTEXT

creation
    make

feature -- Defined features

    name: STRING

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


feature {NONE} -- Creation

    make(new_name: STRING; new_id: INTEGER) is
    do
        id := new_id
        name := new_name
    end

end -- ONGOING_CONSTRUCTION
