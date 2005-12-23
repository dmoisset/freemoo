class COLONY_PRODUCING_VIEW

inherit
    COLONY_VIEW

creation
    make

feature {NONE} -- Creation

    make(w: WINDOW; where: RECTANGLE) is
    do
        my_connect_identifier := agent update_producing
        window_make(w, where)
        create shadow.make(Current, 2, location.height - 20, imgs @ 1)
        create buy_button.make(Current, 2, location.height - 20,
                            imgs @ 0, imgs @ 2, imgs @ 3)
        buy_button.set_click_handler(agent buy)
        buy_button.hide
    end

feature -- Callbacks

    update_producing is
    local
        buyable: BOOLEAN
    do
        buyable := colony.buying_price <= colony.owner.money
        if buyable and colony.producing.is_buyable then
            shadow.hide
            buy_button.show
        else
            buy_button.hide
            shadow.show
        end
    end

    buy is
    do
        print("Bought!%N")
    end

feature {NONE} -- Widgets

    buy_button: BUTTON_IMAGE

    shadow: WINDOW_IMAGE

feature {NONE} -- Images

    imgs: ARRAY[IMAGE] is
    once
        create Result.make(0, 3)
        Result.put(create {IMAGE_FMI}.make_from_file("client/colony-window/buy-button-n.fmi"), 0)
        Result.put(create {IMAGE_FMI}.make_from_file("client/colony-window/buy-button-u.fmi"), 1)
        Result.put(create {IMAGE_FMI}.make_from_file("client/colony-window/buy-button-p.fmi"), 2)
        Result.put(create {IMAGE_FMI}.make_from_file("client/colony-window/buy-button-d.fmi"), 3)
    end

end -- class COLONY_PRODUCING_VIEW
