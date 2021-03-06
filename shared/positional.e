deferred class POSITIONAL
    -- Object with a map position

feature -- Access

    distance_to, infix "|-|" (other: POSITIONAL): REAL is
    do
        Result := ((x-other.x)*(x-other.x) + (y-other.y)*(y-other.y)).sqrt.to_real
        if Result < epsilon then Result := 0 end
    ensure
        Result >= 0
    end

    distance_to_segment(o1, o2: POSITIONAL): REAL is
        -- How close to Current do you pass when going from `o1'  to `o2'?
    local
        x2, y2: REAL
    do
        
        if is_approx(o1.x, o2.x) then
            Result := (o1.x - x).abs
        elseif is_approx(o1.y, o2.y) then
            Result := (o1.y - y).abs
        else
            x2 := o2.x - o1.x
            y2 := o2.y - o1.y
            Result := (x2*(y - o1.y)-(x - o1.x)*y2).abs / ((x2*x2+y2*y2).sqrt).to_real
        end
    end
    
feature -- Operations

    move_to (other: POSITIONAL) is
        -- copy position from `other'
    require
        other /= Void
    do
        x := other.x
        y := other.y
    ensure
        distance_to (other) = 0
    end

    move_towards (other: POSITIONAL; dist: REAL) is
        -- Get closer to `other' by `dist'. When
        -- `dist' >= distance_to (`other') stop right on `other'
    require
        other /= Void
        dist >= 0
    local
        dx, dy, movedist: REAL
    do
        movedist := distance_to (other).min (dist)
        dx := (other.x - x) / distance_to (other) * movedist
        dy := (other.y - y) / distance_to (other) * movedist
        x := x + dx
        y := y + dy
        if is_approx (distance_to (other), 0) then move_to (other) end
    ensure
        is_approx (distance_to (other), (old distance_to(other) - dist).max (0))
    end

    serialize_on (s: SERIALIZER2) is
    do
        s.add_tuple (<<x.box, y.box>>)
    end

    unserialize_from (s: UNSERIALIZER) is
    do
        s.get_real
        x := s.last_real
        s.get_real
        y := s.last_real
    end

feature {POSITIONAL, PROJECTION, MAP_GENERATOR} -- Position info

    x, y: REAL

feature {NONE} -- Internal

    epsilon: REAL is 0.00001
        -- How close is enough to be "the same place"

    is_approx (a, b: REAL): BOOLEAN is
        -- `a' is approximately equal to `b'. (i.e., |`a'-`b'|<`epsilon' )
    do
        Result := (a-b).abs < epsilon
    end

invariant
    distance_to (Current) = 0

end -- deferred class POSITIONAL
