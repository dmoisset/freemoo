class ENEMY_SELECTION_DIALOG
    -- Dialog to select a target for engagement

inherit
    STAR_VIEW
        rename
            make as star_view_make
        redefine
            planet_click, update_title
        end
    CLIENT

creation make

feature {NONE} -- Creation

    make (w: WINDOW; where: RECTANGLE; f: C_FLEET; id: INTEGER) is
    require
        f /= Void
        f.orbit_center /= Void
    do
        fleet := f
        dialog_id := id
        star_view_make (w, where, f.orbit_center, server.game_status, server.galaxy)
        close_button.set_click_handler (agent cancel_selection)
        fleets_orbiting.set_fleet_click_handler (agent fleet_click)
        update_title
    end

feature {NONE} -- Callbacks

    planet_click (p: C_PLANET) is
    local
        s: SERIALIZER2
    do
        if p.colony /= Void and then p.colony.owner /= fleet.owner then
            create s.make
            s.add_integer (p.colony.owner.id)
            s.add_integer (p.orbit)
            server.dialog (dialog_id, s.serialized_form)
            remove
        end
    end

    fleet_click (f: C_FLEET) is
    local
        s: SERIALIZER2
    do
        if f.owner /= fleet.owner and then no_colony_from (f.owner) then
            create s.make
            s.add_integer (f.owner.id)
            s.add_integer (0)
            server.dialog (dialog_id, s.serialized_form)
            remove
        end
    end

    no_colony_from (p: PLAYER): BOOLEAN is
        -- Fleet engagement directly to `p' fleets are allowed
    local
        i: INTEGER
    do
        Result := star.has_info
        from i := 1 until not Result or i > star.Max_planets loop
            Result :=
                star.planet_at (i) = Void or else
                star.planet_at (i).colony = Void or else
                star.planet_at (i).colony.owner /= p
            i := i + 1
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
            name_label.set_text("Select combat at " + star.name)
        else
            name_label.set_text("Scanning targets... ")
        end
    end
    
feature {NONE} -- Internal

    fleet: C_FLEET

    dialog_id: INTEGER

end -- ENEMY_SELECTION_DIALOG
