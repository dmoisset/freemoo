class BUTTON_PLANET

inherit
    MAP_CONSTANTS
    BUTTON_IMAGE
        rename make as butimage_make
        redefine handle_event end

creation make

feature {NONE}  -- Creation

    make (w: STAR_VIEW; x, y: INTEGER; i1, i2, i3: IMAGE; p: PLANET) is
    do
        planet := p
        sv_parent := w
        butimage_make(w, x, y, i1, i2, i3)
    end

feature {NONE} -- Implementation

    planet: PLANET

feature -- Redefined Features

    handle_event (event: EVENT) is
    local
        e: EVENT_MOUSE_NOTIFY
        m: EVENT_MOUSE_MOVE
    do
        Precursor (event)
        if not event.handled then
            e ?= event
            if e /= Void then
                if e.is_enter then
                    sv_parent.enter_planet (planet)
                else
                    sv_parent.leave_planet (planet)
                end
                event.set_handled
            end
            m ?= event
            if m /= Void then m.set_handled end
        end
    end

feature {NONE} -- Internal

    sv_parent: STAR_VIEW

end -- class BUTTON_PLANET