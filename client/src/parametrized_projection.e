class PARAMETRIZED_PROJECTION
    -- Projection with scaling, rotation and translation capabilities

inherit PROJECTION
        redefine project

creation make, make_identity

feature -- Access

    matrix: ARRAY2 [REAL]
        -- Transformation matrix for scaling and rotation

    dx: REAL

    dy: REAL
        -- Translation values

feature -- Operations

    project (p: POSITIONAL) is
        -- Assigns [A] := [B] * [C] + [D] where
        --    [A] is the column matrix [Current.x Current.y]
        --    [B] is Current.matrix
        --    [C] is the column matrix [p.x p.y]
        --    [D] is the column matrix [dx dy]
    do
        x := matrix.item (1, 1) * p.x + matrix.item (1, 2) * p.y + dx
        y := matrix.item (2, 1) * p.x + matrix.item (2, 2) * p.y + dy
    end

    translate (deltax, deltay: REAL) is
        -- Offset current projection by [deltax deltay]
    do
        dx := dx + deltax
        dy := dy + deltay
    end

    scale (sex, sey: REAL) is
        -- Scale current projection `sex' times in x and `sey' times in y
    do
        matrix.put (sex * matrix.item (1, 1), 1, 1)
        matrix.put (sex * matrix.item (1, 2), 1, 2)
        matrix.put (sey * matrix.item (2, 1), 2, 1)
        matrix.put (sey * matrix.item (2, 2), 2, 2)
    end

    rotate (a: REAL) is
        -- Rotate current projection `a' _radians_
    local
        tmpm: ARRAY2[REAL]
    do
        !!tmpm.make (1, 2, 1, 2)
        tmpm.put ((a.cos * matrix.item (1, 1) + a.sin * matrix.item (2, 1)).to_real, 1, 1)
        tmpm.put ((a.cos * matrix.item (1, 2) + a.sin * matrix.item (2, 2)).to_real, 1, 2)
        tmpm.put ((-a.sin * matrix.item (1, 1) + a.cos * matrix.item (2, 1)).to_real, 2, 1)
        tmpm.put ((-a.sin * matrix.item (1, 2) + a.cos * matrix.item (2, 2)).to_real, 2, 2)
        matrix := tmpm
    end


feature {NONE} -- creation

    make_identity is
    do
        !!matrix.make (1, 2, 1, 2)
        matrix.put (1, 1, 1)
        matrix.put (1, 2, 2)
    end

    make (m: ARRAY2 [REAL];  deltax, deltay: REAL) is
    require
        (m.count1 = 2) and (m.count2 = 2)
        (m.lower1 = 1) and (m.lower2 = 1)
    do
        matrix := m
        dx := deltax
        dy := deltay
    ensure
        matrix = m
        dx = deltax
        dy = deltay
    end

invariant

    right_size_matrix: (matrix.line_count = 2) and (matrix.column_count = 2)
    matrix_starts_on_one: (matrix.lower1 = 1) and (matrix.lower2 = 1)

end -- class PARAMETRIZED_PROJECTION