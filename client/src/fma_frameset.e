class FMA_FRAMESET

inherit
    ANIMATION_LOADER

creation
    make

feature {NONE} -- Creation

    init_representation (count: INTEGER) is
    do
        !!images.make (1, count)
        !!positions.make (1, count)
    end

    add_frame (index: INTEGER; s: SDL_SURFACE; ox, oy: INTEGER) is
    local
        img: IMAGE
        r: RECTANGLE
    do
        !SDL_IMAGE!img.make_from_surface (s)
        r.set_with_size (ox, oy, s.width, s.height)
        images.put (img, index+1)
        positions.put (r, index+1)
    end

feature -- Access

    images: ARRAY [IMAGE]
        -- Animation images

    positions: ARRAY [RECTANGLE]

feature -- Operations

    item: IMAGE is
    do
        Result := images @ 1
    end

    start is do end

    next is do end

invariant
    images /= Void
    images.count > 0

end -- class FMA_FRAMESET