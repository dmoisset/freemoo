class IMAGE_FMI

inherit
    SDL_IMAGE
    redefine make_from_file end

creation
    make_from_file

feature {NONE} -- Creation

    make_from_file (path: STRING) is
        -- Load from FMI in a package
    require else
        path /= Void
    local
        p: PKG_USER
        tried: BOOLEAN
    do
        if not tried then
            p.pkg_system.open_file (path)
            if p.pkg_system.last_file_open /= Void then
                make_from_surface (fmi_load (p.pkg_system.last_file_open.to_external))
                p.pkg_system.last_file_open.disconnect
            end
        else
            make (10, 10)
        end
    rescue
        if p.pkg_system.last_file_open.is_connected then
            p.pkg_system.last_file_open.disconnect
        end
        if not tried then
            print ("Error loading FMI: "+path+"%N")
            tried := True
            retry
        end
    end

feature {NONE} -- External

    fmi_load (p: POINTER): POINTER is
    require
        not p.is_null
    external "C use %"src/C/img_loader.h%""
    alias "FMI_Load"
    ensure
        not Result.is_null
    end

end -- class IMAGE_FMI
