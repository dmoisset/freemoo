class BUTTON_PLANET

inherit
    MAP_CONSTANTS
    BUTTON_IMAGE
        rename make as butimage_make
        redefine handle_event end

creation make

feature {NONE}  -- Creation
    make (w: WINDOW; x, y: INTEGER; i1, i2, i3: IMAGE; p: PLANET) is
    do
        planet := p
        butimage_make(w, x, y, i1, i2, i3)
    end

feature {NONE} -- Implementation
    planet: PLANET

feature -- Redefined Features

    handle_event (event: EVENT) is
    local
        e: EVENT_MOUSE_NOTIFY
        sview: STAR_VIEW
    do
        Precursor (event)
        if not event.handled then
            e ?= event
            sview ?= parent
            if e /= Void and then e.is_enter and then sview /= Void then
                if planet.type = type_gasgiant then
                    sview.set_planet_text ("Gas Giant (Uninhabitable)")
                else
                    sview.set_planet_text (sview.model.name + " " +
                             roman @ planet.orbit + "%N" +
                             plsize_names @ planet.size + ", " +
                             climate_names @ planet.climate + "%N" +
                             gravity_names @ planet.gravity)
                end
            end
        end
    end

feature {NONE} -- Internal

    roman: ARRAY[STRING] is
    once
        Result := << "I", "II", "III", "IV", "V" >>
    end

end -- class BUTTON_PLANET