class ANIMATED_LINE
    -- Flashy glowing directed line.

inherit ANIMATION

creation make

feature {NONE} -- Creation

    make (x1, y1, x2, y2, r, g, b: INTEGER) is
        -- Create an animated line going from (`x1', `y1') to (`x2', `y2'),
        -- and with color (`r', `g', `b')
    require
        valid_color: r.in_range(0, 255) and g.in_range(0, 255)
                     and b.in_range(0, 255)
    local
        int: INTEGER
        dash: ARRAY[INTEGER]
    do
        !!pic.make(x1, y1, x2, y2, r, g, b)
        !!dash.make(1, 2)
        int := 5
        dash.put(int, 1)
        int := 2
        dash.put(int, 2)
        pic.set_dash(dash)
    end

feature -- Inherited features

    item: IMAGE is
    do
        Result := pic
    end

    width: INTEGER is
    do
        Result := pic.width
    end

    height: INTEGER is
    do
        Result := pic.height
    end

    start is
    do
        pic.set_offset(0)
    end

    next is
    do
        pic.set_offset(pic.offset + 1)
    end

feature {NONE} -- Inplementation

    pic: SDL_LINE_IMAGE

end -- class ANIMATED_LINE