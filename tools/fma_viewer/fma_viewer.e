class FMA_VIEWER

inherit
    PKG_USER
    ARGUMENTS

creation make

feature {NONE} -- Creation

    make is
    local
        a: ANIMATION
        d: SDL_DISPLAY
        w1: WINDOW
    do
        if argument_count.in_range (1, 2) then

            -- Init and set background
            !!d.make (640, 480, 16, False)
            !WINDOW_ANIMATED!w1.make (d.root, 0, 0,
                create {ANIMATION_SEQUENTIAL}.make (<<
                    create {SDL_SOLID_IMAGE}.make (640, 480, 30, 30, 30)
                >>)
            )


            if argument_count = 1 or else not argument(1).is_equal ("-t") then
                !ANIMATION_FMA!a.make (argument (argument_count))
            else
                !ANIMATION_FMA_TRANSPARENT!a.make (argument (argument_count))
            end
            print ("size="+a.width.to_string+"x"+a.height.to_string+"%N")

            !WINDOW_ANIMATED!w1.make (d.root, 0, 0, a)

            -- Main loop
            d.set_timer_interval (100)
            d.do_event_loop
            d.close
        else
            print ("Usage: fma_viewer [-t] <animation.fma>%N")
        end
    rescue
        if d /=Void then d.close end
    end

end -- class FMA_VIEWER
