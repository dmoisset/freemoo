class PLANET_SELECTION_DIALOG
    -- Dialog to select a planet from a star system (Used for colonization)

inherit
    STAR_VIEW
    rename
        make as star_view_make
    redefine
        planet_click, make_fleets_orbiting, update_title
    end
    CLIENT

creation make

feature {NONE} -- Creation

    make (w: WINDOW; where: RECTANGLE; f: C_FLEET; id: INTEGER) is
    require
        f /= Void
        f.orbit_center /= Void
    local
        i: IMAGE_FMI
        p: MOUSE_POINTER
    do
        fleet := f
        dialog_id := id
        star_view_make (w, where, f.orbit_center, server.game_status, server.galaxy)
        close_button.set_click_handler (agent cancel_selection)
        create i.make_from_file ("client/star-view/colonize-pointer.fmi")
        create p.make (i, 4, 24)
        set_pointer (p)
        update_title
    end

    make_fleets_orbiting(g: C_GALAXY) is
    do
    end

feature {NONE} -- Callbacks

    planet_click(p: C_PLANET) is
    local
        s: SERIALIZER2
    do
        if p.is_colonizable then
            create s.make
            s.add_integer (p.orbit)
            server.dialog (dialog_id, s.serialized_form)
            remove
        end
    end

    cancel_selection is
    local
        s: SERIALIZER2
    do
        create s.make
        s.add_integer (0)
        server.dialog (dialog_id, s.serialized_form)
        remove
    end

    update_title is
    do
        if star.has_info then
            name_label.set_text("Select planet for colonization on " + star.name)
        else
            name_label.set_text("Colony ship arriving... ")
        end
    end
    
feature {NONE} -- Internal

    fleet: C_FLEET

    dialog_id: INTEGER

end -- PLANET_SELECTION_DIALOG
