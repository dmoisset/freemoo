deferred class CONNECT_WINDOW_GUI
    -- Automatically generated by VEGlade -- do not edit, inherit

inherit
    VEGTK_CALLBACK_HANDLER
    VEGTK_HELPER
    GTK_CONSTANTS

feature {NONE} -- Creation

    make is
        -- Build GUI
    do
        !!connect_window.make (GTK_WINDOW_DIALOG)
        make_accel_group
        connect_window.set_title ("Connect to FreeMOO server")
        connect_window.set_position (GTK_WIN_POS_CENTER)
        connect_window.set_modal (true)
        connect_window.set_policy (false, false, true)
        !!vbox1.make (false, 3)
        vbox1.set_border_width (3)
        vbox1.show
        !!table1.make (2, 2, false)
        table1.set_border_width (3)
        table1.set_row_spacings (3)
        table1.set_col_spacings (3)
        table1.show
        !!port_entry.make
        port_entry.set_text ("3002")
        port_entry.show
        table1.attach (port_entry, 1, 2, 1, 2, Gtk_expand and Gtk_fill, Gtk_attach_normal, 0, 0)
        !!host_entry.make
        host_entry.set_text ("localhost")
        host_entry.show
        table1.attach (host_entry, 1, 2, 0, 1, Gtk_expand and Gtk_fill, Gtk_attach_normal, 0, 0)
        !!label2.make ("")
        label2.set_alignment (0.000000, 0.500000)
        label2.set_padding (0, 0)
        label2.set_justify (GTK_JUSTIFY_CENTER)
        label2.show
        table1.attach (label2, 0, 1, 1, 2, Gtk_fill, Gtk_attach_normal, 0, 0)
        !!label1.make ("")
        label1.set_alignment (0.000000, 0.500000)
        label1.set_padding (0, 0)
        label1.set_justify (GTK_JUSTIFY_CENTER)
        label1.show
        table1.attach (label1, 0, 1, 0, 1, Gtk_fill, Gtk_attach_normal, 0, 0)
        vbox1.pack_start (table1, true, true, 0)
        !!hbox1.make (false, 3)
        hbox1.set_border_width (3)
        hbox1.show
        status_label := new_label ("Please, enter server address and port.")
        status_label.set_alignment (0.500000, 0.500000)
        status_label.set_padding (0, 0)
        status_label.set_justify (GTK_JUSTIFY_CENTER)
        status_label.set_line_wrap (true)
        status_label.show
        hbox1.pack_start (status_label, false, false, 0)
        !!status_bar.make
        status_bar.set_usize (100, -2)
        status_bar.configure (0.000000, 0.000000, 100.000000)
        status_bar.set_bar_style (GTK_PROGRESS_CONTINUOUS)
        status_bar.set_orientation (GTK_PROGRESS_LEFT_TO_RIGHT)
        status_bar.set_activity_mode (true)
        status_bar.set_show_text (false)
        status_bar.set_format_string ("%%P %%%%")
        status_bar.set_text_alignment (0.500000, 0.500000)
        status_bar.show
        hbox1.pack_end (status_bar, false, false, 0)
        vbox1.pack_start (hbox1, false, true, 0)
        !!hseparator1.make
        hseparator1.show
        vbox1.pack_start (hseparator1, false, true, 3)
        !!hbuttonbox1.make
        hbuttonbox1.set_layout (GTK_BUTTONBOX_END)
        hbuttonbox1.set_child_ipadding (0, 0)
        hbuttonbox1.show
        connect_button := new_button ("_Connect", $connect)
        connect_button.set_flags (Gtk_can_default)
        connect_button.show
        hbuttonbox1.add (connect_button)
        quit_button := new_button ("_Quit", $destroy)
        quit_button.set_flags (Gtk_can_default)
        quit_button.show
        hbuttonbox1.add (quit_button)
        vbox1.pack_start (hbuttonbox1, false, true, 0)
        connect_window.add (vbox1)

        host_entry.grab_focus
        set_label_to (label2, "_Port:", port_entry)
        set_label_to (label1, "_Server address:", host_entry)
        connect_button.grab_default
        signal_connect (connect_window, "delete_event", $delete_event)
        connect_window.add_accel_group (current_accel_group)
        connect_window.show

    end

feature {NONE} -- Widgets

    connect_window: GTK_WINDOW
    vbox1: GTK_VBOX
    table1: GTK_TABLE
    port_entry: GTK_ENTRY
    host_entry: GTK_ENTRY
    label2: GTK_LABEL
    label1: GTK_LABEL
    hbox1: GTK_HBOX
    status_label: GTK_LABEL
    status_bar: GTK_PROGRESS_BAR
    hseparator1: GTK_HSEPARATOR
    hbuttonbox1: GTK_HBUTTON_BOX
    connect_button: GTK_BUTTON
    quit_button: GTK_BUTTON

feature {NONE} -- Callbacks

    connect (data: ANY; cb_data: VEGTK_CALLBACK_DATA) is
    deferred end

    destroy (data: ANY; cb_data: VEGTK_CALLBACK_DATA) is
    deferred end

    delete_event (data: ANY; cb_data: VEGTK_CALLBACK_DATA) is
    deferred end

end -- class CONNECT_WINDOW_GUI
