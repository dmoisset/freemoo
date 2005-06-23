class PLANET_SELECTION_DIALOG
    -- Dialog to select a planet from a star system (Used for colonization)

inherit
    STAR_VIEW
    redefine
        make, planet_click, make_fleets_orbiting
    end

creation make

feature {NONE} -- Creation

    make (w: WINDOW; where: RECTANGLE; s: C_STAR; new_status: C_GAME_STATUS; g: C_GALAXY) is
    do
        Precursor(w, where, s, new_status, g)
        name_label.set_text("Select planet for colonization on " + star.name)
    end

    make_fleets_orbiting(g: C_GALAXY) is
    do
    end

feature -- Commanding

    planet_click(p: C_PLANET) is
    do
        if selection_handler /= Void then
            selection_handler.call([p, fleet])
        end
    end

    set_selection_callback(p: PROCEDURE[ANY, TUPLE[C_PLANET, C_FLEET]]) is
    do
        selection_handler := p
    end

    set_fleet(f: C_FLEET) is
        -- Provide the fleet that will do stuff on the colonization
    do
        fleet := f
    end

feature {NONE} -- Internal

    fleet: C_FLEET

    selection_handler: PROCEDURE[ANY, TUPLE[C_PLANET, C_FLEET]]

end -- PLANET_SELECTION_DIALOG
