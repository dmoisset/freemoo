class COLORS
    -- Map from player numbers to colors

inherit
    PLAYER_CONSTANTS

feature {NONE}

    color_map: ARRAY [GDK_COLOR] is
    require
        min_color = 0
        max_color = 7
        -- Colors are hardcoded here
    once
        Result := <<new_color (49152,     0,     0),
                    new_color (    0,     0, 49152),
                    new_color (58982, 62258, 13107),
                    new_color (49152, 49152, 49152),
                    new_color (    0, 49152,     0),
                    new_color (39321, 32768,     0),
                    new_color (32768,     0, 39321),
                    new_color (52428, 32768,     0)
                  >>
        Result.reindex (min_color)
    ensure
        Result.lower = min_color
        Result.upper = max_color
    end

    new_color (r, g, b: INTEGER): GDK_COLOR is
    do
        !!Result.make_with_values (r, g, b)
        Result.set_pixel (65536*(r//256)+256*(g//256)+(b//256))
    end

end -- class COLORS