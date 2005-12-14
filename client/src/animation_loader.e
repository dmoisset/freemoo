deferred class ANIMATION_LOADER

inherit
    ANIMATION

feature {NONE} -- Creation template

    make (path: STRING) is
        -- Load from package `path'
    local
        p: PKG_USER
        fma: POINTER
        count, i: INTEGER
        imgs: NATIVE_ARRAY [POINTER]
        lx, ly: NATIVE_ARRAY [INTEGER]
        s: SDL_IMAGE

        tried: BOOLEAN
    do
        if not tried then
            width := 0
            height := 0
            p.pkg_system.open_file (path)
            if p.pkg_system.last_file_open /= Void then
                fma := load_anim (p.pkg_system.last_file_open.to_external)
                count := FMA_count (fma)
                imgs := imgs.from_pointer (FMA_items (fma))
                lx := lx.from_pointer (FMA_x (fma))
                ly := ly.from_pointer (FMA_y (fma))
                init_representation (count)
                from i := 0 until i = count loop
                    !!s.make_from_surface (imgs.item (i))
                    width := width.max (s.width+lx.item (i))
                    height := height.max (s.height+ly.item (i))
                    add_frame (i, s, lx.item (i), ly.item (i))
                    i := i + 1
                end
                loop_frame := FMA_loopstart (fma)
                free_FMA (fma)
                p.pkg_system.last_file_open.disconnect
            end
        else
            -- Fallback to dummy image
            std_error.put_string ("Error loading FMA: "+path+". Fallback to dummy image%N")
            init_representation (1)
            width := 10
            height := 10
            add_frame (0, create {SDL_IMAGE}.make (10, 10), 0, 0)
        end
        start
    rescue
        if p.pkg_system.last_file_open.is_connected then
            p.pkg_system.last_file_open.disconnect
        end
        if not fma.is_null then
            free_FMA (fma)
            fma := default_pointer
        end
        if not tried then
            tried := True
            retry
        end
    end

    init_representation (count: INTEGER) is
        -- Prepare representation before adding up to `count' frames
    deferred
    end

    add_frame (index: INTEGER; s: SDL_IMAGE; ox, oy: INTEGER) is
        -- Add `s' as frame at `index' with offset vector (`ox',`oy')
    require
        s /= Void
        width >= ox+s.width and height >= oy+s.height
    deferred
    end

feature -- Access

    width, height: INTEGER

feature {NONE} -- Representation

    loop_frame: INTEGER
        -- First frame of the loop

feature {NONE} -- External

    load_anim (f: POINTER): POINTER is
        -- Loads an animation from FILE* `f', returns an FMA_t *
    external "C use %"src/C/img_loader.h%""
    ensure
        not Result.is_null
    end

    free_FMA (a: POINTER) is
        -- Deallocates a FMA_t *
    external "C use %"src/C/img_loader.h%""
    alias "free_FMA"
    end

    FMA_count (a: POINTER): INTEGER is
    external "[
                C struct FMA_t get count use "src/C/img_loader.h"
             ]"
    end

    FMA_loopstart (a: POINTER): INTEGER is
    external "[
                C struct FMA_t get loopstart use "src/C/img_loader.h"
             ]"
    end

    FMA_items (a: POINTER): POINTER is
    external "[
                C struct FMA_t get items use "src/C/img_loader.h"
             ]"
    end

    FMA_x (a: POINTER): POINTER is
    external "[
                C struct FMA_t get x use "src/C/img_loader.h"
             ]"
    end

    FMA_y (a: POINTER): POINTER is
    external "[
                C struct FMA_t get y use "src/C/img_loader.h"
             ]"
    end

end -- class ANIMATION_LOADER
