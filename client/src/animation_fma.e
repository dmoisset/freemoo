class ANIMATION_FMA

inherit
    ANIMATION_LOADER

creation
    make

feature {NONE} -- Creation

    init_representation (count: INTEGER) is
    do
        !!images.make (0, count-1)
    end

    add_frame (index: INTEGER; s: SDL_IMAGE; ox, oy: INTEGER) is
    local
        img: IMAGE_OFFSET
    do
        !!img.make (s, ox, oy)
        images.put (img, index)
    end

feature -- Access

    item: IMAGE is
    do
        Result := images @ position
    end

feature -- Operations

    start is
        -- Go to first frame of the animation
    do
        position := images.lower
    end

    next is
        -- Go to next frame of the animation
    local
        old_pos: INTEGER
    do
        old_pos := position
        position := position + 1
        if position > images.upper then position := loop_frame end
        unchanged := (position = old_pos)
    end

feature {NONE} -- Representations

    images: ARRAY [IMAGE]
        -- Animation images

    position: INTEGER
        -- Current frame

invariant
    images /= Void
    images.count >= 1
    images.valid_index (position)
    images.valid_index (loop_frame)

end -- class ANIMATION_FMA