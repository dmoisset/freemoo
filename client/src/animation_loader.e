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
        s: SDL_SURFACE
    do
        width := 0
        height := 0
        p.pkg_system.open_file (path)
        if p.pkg_system.last_file_open /= Void then
            fma := load_anim (p.pkg_system.last_file_open.to_external)
            if not fma.is_null then
                count := FMA_count (fma)
                imgs := imgs.from_pointer (FMA_items (fma))
                lx := lx.from_pointer (FMA_x (fma))
                ly := ly.from_pointer (FMA_y (fma))
                init_representation (count)
                from i := 0 until i = count loop
                    !!s.make_from_surface (imgs.item (i))
                    add_frame (i, s, lx.item (i), ly.item (i))
                    width := width.max (s.width+lx.item (i))
                    height := height.max (s.height+ly.item (i))
                    i := i + 1
                end
                loop_frame := FMA_loopstart (fma)
                free_FMA (fma)
            end
            p.pkg_system.last_file_open.disconnect
        end
        start
    end

    init_representation (count: INTEGER) is
        -- Prepare representation before adding up to `count' frames
    deferred
    end

    add_frame (index: INTEGER; s: SDL_SURFACE; ox, oy: INTEGER) is
        -- Add `s' as frame at `index' with offset vector (`ox',`oy')
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