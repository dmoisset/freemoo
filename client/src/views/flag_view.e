class FLAG_VIEW
    -- Gtk view for a player flag

inherit
    VIEW [C_PLAYER_LIST]
    CLIENT
    VEGTK_CALLBACK_HANDLER
    COLORS

creation
    make

feature {NONE} -- Creation

    make (new_model: C_PLAYER_LIST) is
        -- build widget as view of `new_model'
    do
        set_model (new_model)
        !!widget.make
        widget.size (80, 100)
        widget.show
        signal_connect (widget, "expose_event", $expose)
        -- Update gui
        on_model_change
    end

feature -- Access

    widget: GTK_DRAWING_AREA
        -- widget reflecting model

feature -- Redefined features

    on_model_change is
        -- Update gui
    do
        widget.draw (Void)
    end

feature {NONE} -- Callbacks

    expose (data: ANY; cb_data: VEGTK_CALLBACK_DATA) is
    require
        server /= Void and then not server.is_closed
        server.player /= Void
    local
        gc: GDK_GC
        c: GDK_COLOR
        ca: BOOLEAN
    do
        !!gc.make (widget.window)
        c := color_map @ server.player.color_id
        ca := widget.get_colormap.alloc_color (c, False, True)
        gc.set_foreground (c)
        widget.window.draw_rectangle (gc, 1, 0, 0, -1, -1)
        cb_data.set_return_value_boolean (False)
    end

end -- FLAG_VIEW