class ANIMATION_FMA_TRANSPARENT

inherit
    ANIMATION_LOADER

creation
    make

feature {NONE} -- Creation

    init_representation (count: INTEGER) is
    do
        !!images.make (0, count-1)
    end

    last_frame: SDL_IMAGE

    add_frame (index: INTEGER; s: SDL_IMAGE; ox, oy: INTEGER) is
    local
        new: SDL_IMAGE
    do
        !!new.make_transparent (width, height)
        if last_frame /= Void then
            last_frame.remove_alpha
            last_frame.blit_fast (new, 0, 0)
            last_frame.enable_alpha
        end
        s.blit_fast (new, ox, oy)
        last_frame := new
        images.put (new, index)
    end

feature -- Access

    item: IMAGE

feature -- Operations

    start is
        -- Go to first frame of the animation
    do
        position := images.lower
        item := images.first
    end

    next is
        -- Go to next frame of the animation
    local
        old_position: INTEGER
    do
        old_position := position
        position := position + 1
        if position > images.upper then position := loop_frame end
        item := images @ position
    end

feature {NONE} -- Representations

    images: ARRAY [SDL_IMAGE]
        -- Animation images

    position: INTEGER
        -- Current frame

invariant
    images /= Void
    images.count >= 1
    images.valid_index (position)
    images.valid_index (loop_frame)

end -- class ANIMATION_FMA_TRANSPARENT