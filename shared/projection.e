class PROJECTION
    -- Projection to a 2D space for a POSITIONAL

feature -- Access

    x, y: REAL
        -- Projected coordinates

feature -- Operations

    project (p: POSITIONAL) is
        -- Set `x', `y' to the projection of `p'
    do
        x := p.x
        y := p.y
    end

end -- class PROJECTION