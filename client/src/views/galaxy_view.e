class GALAXY_VIEW
    -- Gtk view for a GALAXY

inherit
    VIEW [C_GALAXY]

creation
    make

feature {NONE} -- Creation

    make (new_model: C_GALAXY) is
        -- build widget as view of `new_model'
    do
        set_model (new_model)
        !!widget.make
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
    local
        gc: GDK_GC
    do
        !!gc.make (widget.window)
        widget.window.draw_rectangle (gc, 1, 0, 0, -1, -1)
        cb_data.set_return_value_boolean (False)
    end

end -- GALAXY_VIEW