class BITMAP_FONT_FMI

inherit
    SDL_BITMAP_FONT
    redefine make end

creation
    make

feature {NONE} -- Creation

    make (filename: STRING) is
    local
        p: PKG_USER
    do
        p.pkg_system.open_file (filename)
        if p.pkg_system.last_file_open /= Void then
            make_from_surface (FMI_Load (p.pkg_system.last_file_open.to_external))
            p.pkg_system.last_file_open.disconnect
        else
            print ("Can't find font file%N")
        end
        !!chr_areas.make (33, 128)
        parse
        remove_alpha
        spacing := (relative_spacing * height).rounded
    end

feature {NONE} -- External

    FMI_Load (p: POINTER): POINTER is
    require
        not p.is_null
    external "C use %"src/C/img_loader.h%""
    alias "FMI_Load"
    ensure
        not Result.is_null
    end

end -- class BITMAP_FONT_FMI
