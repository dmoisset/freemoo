class STAR_MAP

create
    make

feature {NONE} -- Creation

    make is
    do
        create limit.make_at(0, 0)
        create stars.make
    end

feature -- Access

    limit: COORDS
        -- Outermost corner of galaxy, opposite to (0, 0)

feature -- Access -- star list

    closest_star_to_or_within (c: COORDS; threshold: INTEGER;
                               exclude: HASHED_SET [STAR]): like last_star is
        -- Star not in `exclude' within `threshold' of `c', or closest
        -- if not found.
    require
        c /= Void
    local
        curs: ITERATOR[like last_star]
        dist: REAL
    do
        dist := Maximum_real
        from
            curs := stars.get_new_iterator_on_items
        until
            curs.is_off or dist < threshold
        loop
            if not exclude.has (curs.item) and (curs.item |-| c) <= dist then
                dist := curs.item |-| c
                Result := curs.item
            end
            curs.next
        end
    ensure
        not exclude.has (Result)
        -- Result |-| c < threshold or else Result is closest to c
    end

--reimplement with closest_star_or_within (...,0,...)
    closest_star_to (c: COORDS; exclude: HASHED_SET [STAR]): like last_star is
        -- Star closest to `c' not in `exclude'
    require
        c /= Void
    local
        curs: ITERATOR[like last_star]
        dist: REAL
    do
        dist := Maximum_real
        from
            curs := stars.get_new_iterator_on_items
        until
            curs.is_off
        loop
            if not exclude.has (curs.item) and (curs.item |-| c) <= dist then
                dist := curs.item |-| c
                Result := curs.item
            end
            curs.next
        end
    ensure
        -- Result is closest to c
    end

    get_new_iterator_on_stars: ITERATOR [like last_star] is
    do
        Result := stars.get_new_iterator_on_items
    end
    
    has_star (sid: INTEGER): BOOLEAN is
        -- Is there a star with id `sid'?
    do
        Result := stars.has (sid)
    end
    
    star_with_id (sid: INTEGER): like last_star is
        -- Star with id `sid'
    require
        has_star (sid)
    do
        Result := stars @ sid
    end

    last_star: STAR

    exists_black_hole_between(s1, s2: POSITIONAL): BOOLEAN is
    require
        s1 /= Void
        s2 /= Void
    local
        sit: ITERATOR[STAR]
        trip: REAL
    do
        from
            sit := get_new_iterator_on_stars
        until sit.is_off or Result loop
            if sit.item.kind = sit.item.kind_blackhole and then
               sit.item.distance_to_segment(s1, s2) < 1.0 then
                trip := s1 |-| s2
                Result := sit.item.distance_to(s1) < trip and then
                          sit.item.distance_to(s2) < trip
            end
            sit.next
        end
    end

feature -- Factory methods

    create_star is
        -- Build a star with proper dynamic type, add it to galaxy and
        -- Store it into last_star.
    do
        create last_star.make_defaults
        stars.add (last_star, last_star.id)
    end

feature {MAP_GENERATOR} -- Generation

    set_limit (l: COORDS) is
    require
        l /= Void
    do
        limit := l
    ensure
        limit = l
    end

feature {MAP_GENERATOR} -- Representation

    stars: HASHED_DICTIONARY [like last_star, INTEGER]
        -- stars in the map, by id

invariant
    stars /= Void

end -- class STAR_MAP