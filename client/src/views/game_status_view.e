class GAME_STATUS_VIEW
    -- View for a GAME_STATUS (game rules)

inherit
    WINDOW
    rename
        make as window_make
    end
    GETTEXT

creation
    make

feature {NONE} -- Representation

   status: C_GAME_STATUS

feature {NONE} -- Creation

    make (w: WINDOW; where: RECTANGLE; new_status: C_GAME_STATUS) is
        -- build widget as view of `new_status'
    local
        a: ARRAY [STRING]
        i: INTEGER
        r: RECTANGLE
        tag: LABEL
    do
        status := new_status
        status.changed.connect (agent update_status)
        window_make (w, where)
        a := <<"Open player slots",
               "Galaxy Size",
               "Galaxy Age",
               "Starting tech level",
               "Tactical Combat",
               "Random Events",
               "Antaran Attacks">>
        from
            i := a.lower
            r.set_with_size (2, 2, 100, 20)
        until i > a.upper loop
            !!tag.make (Current, r, a @ i)
            tag.set_h_alignment (0)
            r.translate (0, 20)
            i := i + 1
        end

        r.set_with_size (110, 2, 100, 20)
        !!open_slots.make (Current, r, "")
        open_slots.set_h_alignment (0)

        r.translate (0, 20)
        !!size.make (Current, r, "")
        size.set_h_alignment (0)

        r.translate (0, 20)
        !!age.make (Current, r, "")
        age.set_h_alignment (0)

        r.translate (0, 20)
        !!tech.make (Current, r, "")
        tech.set_h_alignment (0)

        r.translate (0, 20)
        !!tactical_combat.make (Current, r, "")
        tactical_combat.set_h_alignment (0)

        r.translate (0, 20)
        !!random_events.make (Current, r, "")
        random_events.set_h_alignment (0)

        r.translate (0, 20)
        !!antarans.make (Current, r, "")
        antarans.set_h_alignment (0)

        -- Update gui
        update_status
    end

feature {NONE} -- Internal

    open_slots,
    size,
    age,
    tech,
    tactical_combat,
    random_events,
    antarans: LABEL

feature -- Redefined features

    update_status is
        -- Update gui
    do
        open_slots.set_text (status.open_slots.to_string)
        size.set_text (sizes @ status.galaxy_size)
        age.set_text (ages @ status.galaxy_age)
        tech.set_text (techs @ status.start_tech_level)

        tactical_combat.set_text (status.tactical_combat.to_string)
        random_events.set_text (status.random_events.to_string)
        antarans.set_text (status.antaran_attacks.to_string)
    end

feature {NONE} -- Constants

    sizes: ARRAY [STRING] is
        -- Names for galaxy sizes
    once
        !!Result.make (0, 3)
        Result.put (l("Small"), 0)
        Result.put (l("Medium"), 1)
        Result.put (l("Large"), 2)
        Result.put (l("Huge"), 3)
    end

    ages: ARRAY [STRING] is
        -- Names for galaxy ages
    once
        !!Result.make (-1, 1)
        Result.put (l("Organic Rich"), -1)
        Result.put (l("Average"), 0)
        Result.put (l("Mineral Rich"), 1)
    end

    techs: ARRAY [STRING] is
        -- Names for technology levels
    once
        !!Result.make (0, 2)
        Result.put (l("Pre-warp"), 0)
        Result.put (l("Average"), 1)
        Result.put (l("Advanced"), 2)
    end

end -- GAME_STATUS_VIEW