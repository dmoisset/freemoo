class STAR
    -- Star system

inherit
    POSITIONAL

feature -- Access

    name: STRING
        -- Star name

    kind: INTEGER
        -- star class: see `kind_*' constants. Determines color, and
        -- possibilities for having planets

    planets: ARRAY [PLANET]
        -- planets orbiting, from inner to outer orbit

feature -- Operations

    add_ship (item: SHIP) is
    do
        galaxy.add_ship (item)
    end

feature -- Constants

    kind_blackhole, kind_bluewhite, kind_orange,
    kind_red, kind_white, kind_yellow: INTEGER is unique
        -- Possible values for `kind'

    kind_min: INTEGER is
        -- Minimum value for `kind'
    once Result := kind_blackhole end

    kind_max: INTEGER is
        -- Maximum value for `kind'
    once Result := kind_yellow end

invariant
    valid_kind: kind.in_range (kind_min, kind_max)

end -- class STAR