class MAIN_WINDOW_GUI
    -- Automatically generated by VEGlade -- do not edit, inherit

inherit
    VEGTK_HELPER
    GTK_CONSTANTS

creation
    make

feature {NONE} -- Creation

    make is
        -- Build GUI
    do
        !!main_window.make (GTK_WINDOW_TOPLEVEL)
        make_accel_group
        main_window.set_title ("FreeMOO")
        main_window.set_position (GTK_WIN_POS_NONE)
        main_window.set_policy (false, true, false)
        !!vpaned1.make
        vpaned1.set_border_width (3)
        vpaned1.show
        !!hbox2.make (false, 3)
        hbox2.show
        !!notebook1.make
        notebook1.set_tab_pos (GTK_POS_BOTTOM)
        notebook1.show
        label42 := new_label ("label42")
        label42.set_alignment (0.500000, 0.500000)
        label42.set_padding (0, 0)
        label42.set_justify (GTK_JUSTIFY_CENTER)
        label42.show
        notebook1.add (label42)
        label15 := new_label ("Map")
        label15.set_alignment (0.500000, 0.500000)
        label15.set_padding (0, 0)
        label15.set_justify (GTK_JUSTIFY_CENTER)
        label15.show
        notebook1.set_tab_label (label42, label15)
        label43 := new_label ("label43")
        label43.set_alignment (0.500000, 0.500000)
        label43.set_padding (0, 0)
        label43.set_justify (GTK_JUSTIFY_CENTER)
        label43.show
        notebook1.add (label43)
        label16 := new_label ("Colonies")
        label16.set_alignment (0.500000, 0.500000)
        label16.set_padding (0, 0)
        label16.set_justify (GTK_JUSTIFY_CENTER)
        label16.show
        notebook1.set_tab_label (label43, label16)
        label44 := new_label ("label44")
        label44.set_alignment (0.500000, 0.500000)
        label44.set_padding (0, 0)
        label44.set_justify (GTK_JUSTIFY_CENTER)
        label44.show
        notebook1.add (label44)
        label18 := new_label ("Planets")
        label18.set_alignment (0.500000, 0.500000)
        label18.set_padding (0, 0)
        label18.set_justify (GTK_JUSTIFY_CENTER)
        label18.show
        notebook1.set_tab_label (label44, label18)
        label45 := new_label ("label45")
        label45.set_alignment (0.500000, 0.500000)
        label45.set_padding (0, 0)
        label45.set_justify (GTK_JUSTIFY_CENTER)
        label45.show
        notebook1.add (label45)
        label17 := new_label ("Fleets")
        label17.set_alignment (0.500000, 0.500000)
        label17.set_padding (0, 0)
        label17.set_justify (GTK_JUSTIFY_CENTER)
        label17.show
        notebook1.set_tab_label (label45, label17)
        label46 := new_label ("label46")
        label46.set_alignment (0.500000, 0.500000)
        label46.set_padding (0, 0)
        label46.set_justify (GTK_JUSTIFY_CENTER)
        label46.show
        notebook1.add (label46)
        label21 := new_label ("Leaders")
        label21.set_alignment (0.500000, 0.500000)
        label21.set_padding (0, 0)
        label21.set_justify (GTK_JUSTIFY_CENTER)
        label21.show
        notebook1.set_tab_label (label46, label21)
        label47 := new_label ("label47")
        label47.set_alignment (0.500000, 0.500000)
        label47.set_padding (0, 0)
        label47.set_justify (GTK_JUSTIFY_CENTER)
        label47.show
        notebook1.add (label47)
        label20 := new_label ("Races")
        label20.set_alignment (0.500000, 0.500000)
        label20.set_padding (0, 0)
        label20.set_justify (GTK_JUSTIFY_CENTER)
        label20.show
        notebook1.set_tab_label (label47, label20)
        label48 := new_label ("label48")
        label48.set_alignment (0.500000, 0.500000)
        label48.set_padding (0, 0)
        label48.set_justify (GTK_JUSTIFY_CENTER)
        label48.show
        notebook1.add (label48)
        label19 := new_label ("Info")
        label19.set_alignment (0.500000, 0.500000)
        label19.set_padding (0, 0)
        label19.set_justify (GTK_JUSTIFY_CENTER)
        label19.show
        notebook1.set_tab_label (label48, label19)
        hbox2.pack_start (notebook1, true, true, 0)
        button1 := new_button ("Turn", default_pointer)
        button1.show
        hbox2.pack_start (button1, false, false, 0)
        vpaned1.add (hbox2)
        !!vbox3.make (false, 3)
        vbox3.show
        !!scrolledwindow2.make (Void, Void)
        scrolledwindow2.set_policy (GTK_POLICY_NEVER, GTK_POLICY_ALWAYS)
        scrolledwindow2.show
        !!text1.make (Void, Void)
        text1.insert (Void, Void, Void, "Hello world!")
        text1.show
        scrolledwindow2.add (text1)
        vbox3.pack_start (scrolledwindow2, true, true, 0)
        !!entry5.make
        entry5.set_text ("chat here")
        entry5.show
        vbox3.pack_start (entry5, false, false, 0)
        vpaned1.add (vbox3)
        main_window.add (vpaned1)

        main_window.add_accel_group (current_accel_group)
        main_window.show

    end

feature {NONE} -- Widgets

    main_window: GTK_WINDOW
    vpaned1: GTK_VPANED
    hbox2: GTK_HBOX
    notebook1: GTK_NOTEBOOK
    label42: GTK_LABEL
    label15: GTK_LABEL
    label43: GTK_LABEL
    label16: GTK_LABEL
    label44: GTK_LABEL
    label18: GTK_LABEL
    label45: GTK_LABEL
    label17: GTK_LABEL
    label46: GTK_LABEL
    label21: GTK_LABEL
    label47: GTK_LABEL
    label20: GTK_LABEL
    label48: GTK_LABEL
    label19: GTK_LABEL
    button1: GTK_BUTTON
    vbox3: GTK_VBOX
    scrolledwindow2: GTK_SCROLLED_WINDOW
    text1: GTK_TEXT
    entry5: GTK_ENTRY

end -- class MAIN_WINDOW_GUI
