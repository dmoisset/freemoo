class ANIMATION_FMA_TRANSPARENT

inherit
    ANIMATION_LOADER

creation
    make

feature {NONE} -- Creation

    init_representation (count: INTEGER) is
    do
        !!surfaces.make (0, count-1)
    end

    last_frame: SDL_SURFACE

    add_frame (index: INTEGER; s: SDL_SURFACE; ox, oy: INTEGER) is
    local
        new: SDL_SURFACE
    do
        !!new.make_transparent (width, height)
        if last_frame /= Void then
            last_frame.remove_alpha
            last_frame.blit_fast (new, 0, 0)
            last_frame.enable_alpha
        end
        s.blit_fast (new, ox, oy)
        last_frame := new
        surfaces.put (new, index)
    end

feature -- Access

    item: IMAGE

feature -- Operations

    start is
        -- Go to first frame of the animation
    do
        position := surfaces.lower
        !SDL_IMAGE!item.make_from_surface (surfaces.first)
    end

    next is
        -- Go to next frame of the animation
    local
        old_position: INTEGER
    do
        old_position := position
        position := position + 1
        if position > surfaces.upper then position := loop_frame end
        if position /= old_position then
            !SDL_IMAGE!item.make_from_surface (surfaces @ position)
        end
    end

feature {NONE} -- Representations

    surfaces: ARRAY [SDL_SURFACE]
        -- Animation images

    position: INTEGER
        -- Current frame

invariant
    surfaces /= Void
    surfaces.count >= 1
    surfaces.valid_index (position)
    surfaces.valid_index (loop_frame)

end -- class ANIMATION_FMA_TRANSPARENT