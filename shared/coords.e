class COORDS
    -- Efective positional

inherit POSITIONAL

creation
    make_at

feature {NONE}
    make_at(xx, yy:REAL) is
    do
        x:=xx
        y:=yy
    end -- make_at

end -- class COORDS
