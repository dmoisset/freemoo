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
        !!pic1.make(x1, y1, x2, y2, r, g, b)
        !!dash.make(1, 2)
        int := 5
        dash.put(int, 1)
        int := 2
        dash.put(int, 2)
        pic1.set_dash(dash)
        pic2 := clone(pic1)
    end

feature -- Inherited features

    item: IMAGE is
    do
        if flag then
            Result := pic1
        else
            Result := pic2
        end
    end

    width: INTEGER is
    do
        Result := pic1.width
    end

    height: INTEGER is
    do
        Result := pic1.height
    end

    start is
    do
        pic1.set_offset(0)
        pic2.set_offset(0)
    end

    next is
    do
        pic1.set_offset(pic1.offset + 1)
        pic2.set_offset(pic1.offset)
        flag := not flag
    end

feature {NONE} -- Inplementation

    pic1, pic2: SDL_LINE_IMAGE

    flag: BOOLEAN

end -- class ANIMATED_LINE