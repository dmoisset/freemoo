class GAME_STATUS_VIEW
    -- Gtk view for a GAME_STATUS

inherit
    VIEW [C_GAME_STATUS]
    VEGTK_HELPER
    GETTEXT

creation
    make

feature {NONE} -- Creation

    make (new_model: C_GAME_STATUS) is
        -- build widget as view of `new_model'
    local
        table: GTK_TABLE
    do
        set_model (new_model)

        !!table.make (7, 2, False)
        table.set_border_width (border_width)
        table.set_row_spacings (border_width)
        table.set_col_spacings (border_width)

        table.attach (new_label (l("Open player slots")), 0, 1, 0, 1, Gtk_fill, Gtk_attach_normal, 0, 0)
        last_label.set_padding (border_width, border_width)
        last_label.set_alignment (0, 0.5)
        table.attach (new_label (l("Galaxy Size")), 0, 1, 1, 2, Gtk_fill, Gtk_attach_normal, 0, 0)
        last_label.set_padding (border_width, border_width)
        last_label.set_alignment (0, 0.5)
        table.attach (new_label (l("Galaxy Age")), 0, 1, 2, 3, Gtk_fill, Gtk_attach_normal, 0, 0)
        last_label.set_padding (border_width, border_width)
        last_label.set_alignment (0, 0.5)
        table.attach (new_label (l("Starting Tech Level")), 0, 1, 3, 4, Gtk_fill, Gtk_attach_normal, 0, 0)
        last_label.set_padding (border_width, border_width)

        open_slots_label := new_label ("?")
        table.attach (last_label, 1, 2, 0, 1, Gtk_fill, Gtk_attach_normal, 0, 0)
        last_label.set_padding (border_width, border_width)
        last_label.set_alignment (0, 0.5)
        size_label := new_label ("?")
        table.attach (last_label, 1, 2, 1, 2, Gtk_fill, Gtk_attach_normal, 0, 0)
        last_label.set_padding (border_width, border_width)
        last_label.set_alignment (0, 0.5)
        age_label := new_label ("?")
        table.attach (last_label, 1, 2, 2, 3, Gtk_fill, Gtk_attach_normal, 0, 0)
        last_label.set_padding (border_width, border_width)
        last_label.set_alignment (0, 0.5)
        tech_label := new_label ("?")
        table.attach (last_label, 1, 2, 3, 4, Gtk_fill, Gtk_attach_normal, 0, 0)
        last_label.set_padding (border_width, border_width)
        last_label.set_alignment (0, 0.5)

        !!tactical_combat_box.make_with_label (l("Tactical Combat"))
        tactical_combat_box.set_sensitive (False)
        table.attach (tactical_combat_box, 0, 2, 4, 5, Gtk_fill, Gtk_attach_normal, 0, 0)
        !!random_events_box.make_with_label (l("Random Events"))
        random_events_box.set_sensitive (False)
        table.attach (random_events_box, 0, 2, 5, 6, Gtk_fill, Gtk_attach_normal, 0, 0)
        !!antarans_box.make_with_label (l("Antaran Attacks"))
        antarans_box.set_sensitive (False)
        table.attach (antarans_box, 0, 2, 6, 7, Gtk_fill, Gtk_attach_normal, 0, 0)

        widget := table
        -- Update gui
        on_model_change
    end

feature -- Access

    widget: GTK_WIDGET
        -- widget reflecting model

feature {NONE} -- Internal

    open_slots_label,
    size_label,
    age_label,
    tech_label: GTK_LABEL

    tactical_combat_box,
    random_events_box,
    antarans_box: GTK_CHECK_BUTTON

feature -- Redefined features

    on_model_change is
        -- Update gui
    do
        open_slots_label.set_text (model.open_slots.to_string)
        size_label.set_text (sizes @ model.galaxy_size)
        age_label.set_text (ages @ model.galaxy_age)
        tech_label.set_text (techs @ model.start_tech_level)

        tactical_combat_box.set_active (model.tactical_combat)
        random_events_box.set_active (model.random_events)
        antarans_box.set_active (model.antaran_attacks)
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