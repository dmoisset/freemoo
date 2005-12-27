class POPUP_INFO

inherit
    WINDOW_MODAL
        rename
            make as make_modal
        end

create
    make

feature {NONE} -- Creation

    make(w: WINDOW; text: STRING) is
    local
        bg: WINDOW_IMAGE
        r: RECTANGLE
        ok_button: BUTTON_IMAGE
        label: MULTILINE_LABEL
    do
        r.set_with_size((w.width - background.width) // 2,
                        (w.height - background.height) // 2,
                        background.width, background.height)
        make_modal(w, r)
        create bg.make(Current, 0, 0, background)
        r.set_with_size(20, 20, width - 40, height - 40)
        create label.make(Current, r, text)
        create ok_button.make(Current, 165, 297,
            create {SDL_IMAGE}.make(0, 0),
            ok_pics @ 1, ok_pics @ 2)

        ok_button.set_click_handler(agent ok)
    end

feature {NONE} -- Widgets

    background: IMAGE is
    once
        create {IMAGE_FMI}Result.make_from_file ("client/pups/popup1.fmi")
    end

    ok_pics: ARRAY[IMAGE] is
    once
        create Result.make(1, 2)
        Result.put(create {IMAGE_FMI}.make_from_file("client/pups/ok1.fmi"), 1)
        Result.put(create {IMAGE_FMI}.make_from_file("client/pups/ok2.fmi"), 2)
    end

feature {NONE} -- Callbacks

    ok is
    do
        remove
    end

end -- class POPUP_INFO
