class ANIMATION_FMA_TRANSPARENT

inherit
    ANIMATION_LOADER

creation
    make

feature {NONE} -- Creation

    init_representation (count: INTEGER) is
    do
        !!surfaces.make (0, count-1)
        !!x_offsets.make (0, count-1)
        !!y_offsets.make (0, count-1)
    end

    add_frame (index: INTEGER; s: SDL_SURFACE; ox, oy: INTEGER) is
    do
        surfaces.put (s, index)
        x_offsets.put (ox, index)
        y_offsets.put (oy, index)
    end

feature -- Access

    item: IMAGE

feature -- Operations

    start is
        -- Go to first frame of the animation
    do
        position := surfaces.lower
        !SDL_SURFACE!canvas.make (width, height)
        !SDL_IMAGE!item.make_from_surface (canvas)
        !SDL_IMAGE!item2.make_from_surface (canvas)
        paint
    end

    next is
        -- Go to next frame of the animation
    local
        tmp: IMAGE
        old_position: INTEGER
    do
        old_position := position
        position := position + 1
        if position > surfaces.upper then position := loop_frame end
        if position /= old_position then
            paint
            tmp := item
            item := item2
            item2 := tmp
        end
    end

feature {NONE} -- Representations

    item2: IMAGE
        -- To change image so window_animated redraws

    canvas: SDL_SURFACE
        -- Surface where the images are drawn

    paint is
        -- Paint current frame over `canvas'
    do
        surfaces.item (position).blit_fast (canvas, x_offsets @ position,
                                                    y_offsets @ position)
    end

    surfaces: ARRAY [SDL_SURFACE]
        -- Animation images

    x_offsets, y_offsets: ARRAY [INTEGER]
        -- Displacements

    position: INTEGER
        -- Current frame

invariant
    surfaces /= Void
    canvas /= Void
    surfaces.count >= 1
    surfaces.valid_index (position)
    surfaces.valid_index (loop_frame)
    surfaces.lower = x_offsets.lower and surfaces.upper = x_offsets.upper
    surfaces.lower = y_offsets.lower and surfaces.upper = y_offsets.upper

end -- class ANIMATION_FMA_TRANSPARENT