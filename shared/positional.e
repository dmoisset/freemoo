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

    serial_form: STRING is
    local
        s: SERIALIZER
    do
        s.serialize ("rr", <<x, y>>)
        Result := s.serialized_form
    end

    unserialize_from (incoming: STRING) is
    local
        rr: REAL_REF
        s: SERIALIZER
    do
        s.unserialize ("rr", incoming)
        rr ?= s.unserialized_form @ 1
        x := rr.item
        rr ?= s.unserialized_form @ 2
        y := rr.item
        incoming.remove_first (s.used_serial_count)
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