class COLONY_PRODUCING_VIEW

inherit
    COLONY_VIEW
    CLIENT
    PRODUCTION_CONSTANTS
    SHIP_PICS

creation
    make

feature {NONE} -- Creation

    make(w: WINDOW; where: RECTANGLE) is
    local
        r: RECTANGLE
    do
        my_connect_identifier := agent update_producing
        window_make(w, where)
        r.set_with_size(0, 0, location.width, 20)
        create name_label.make(Current, r, "")
        r.set_with_size(90, location.height - 18, location.width - 90, 15)
        create missing_label.make(Current, r, "")
        create shadow.make(Current, 2, location.height - 20, buy_imgs @ 1)
        create buy_button.make(Current, 2, location.height - 20,
                            buy_imgs @ 0, buy_imgs @ 2, buy_imgs @ 3)
        buy_button.set_click_handler(agent buy)
        buy_button.hide
    end

feature -- Callbacks

    update_producing is
    local
        buyable: BOOLEAN
        r: RECTANGLE
        produced: INTEGER
    do
        -- Show product
        if showing_product /= colony.producing.id then
            if app_pic /= Void then
                app_pic.remove
            end
            create app_pic.make(Current, 1, 1, get_img(colony.producing.id))
            r.set_with_size((location.width - app_pic.width) // 2,
                            (location.height - 18 - app_pic.height) // 2,
                            app_pic.width, app_pic.height)
            app_pic.move(r)
            name_label.set_text(colony.producing.name)
            app_pic.send_behind(buy_button)
        end
        -- Show missing turns
        if colony.producing.is_buyable then
            produced := (colony.industry.total - colony.industry_consumption).floor
            if produced <= 0 then
                missing_label.set_text("(No production)")
            else
                missing_label.set_text(((colony.producing.cost(colony)
                            - colony.produced) / produced).ceiling.max(1).to_string
                            + " turn(s)")
            end
        else
            missing_label.set_text("")
        end
        -- Update 'buy' button
        buyable := colony.buying_price <= colony.owner.money
        if buyable and colony.producing.is_buyable and not colony.has_bought and
            colony.produced < colony.producing.cost(colony) then
            shadow.hide
            buy_button.show
        else
            buy_button.hide
            shadow.show
        end
    end

    buy is
    require
        not colony.has_bought
        colony.producing.is_buyable
        colony.buying_price <= colony.owner.money
        colony.produced < colony.producing.cost(colony)
    do
        server.buy_production_at(colony)
    end

feature {NONE} -- Widgets

    buy_button: BUTTON_IMAGE

    shadow: WINDOW_IMAGE

    app_pic: WINDOW_IMAGE

    name_label, missing_label: LABEL

feature {NONE} -- Representation

    showing_product: INTEGER

    buy_imgs: ARRAY[IMAGE] is
    once
        create Result.make(0, 3)
        Result.put(create {SDL_IMAGE}.make(0, 0), 0)
        Result.put(create {IMAGE_FMI}.make_from_file("client/colony-window/buy-button-u.fmi"), 1)
        Result.put(create {IMAGE_FMI}.make_from_file("client/colony-window/buy-button-p.fmi"), 2)
        Result.put(create {IMAGE_FMI}.make_from_file("client/colony-window/buy-button-d.fmi"), 3)
    end

    imgs: ARRAY[IMAGE] is
        -- Array with produt images.  Don't access directly! use get_img
    once
        create Result.make(product_min, product_max)
    end

    filenums: HASHED_DICTIONARY[INTEGER, INTEGER] is
        -- Maps product_xxxx constants to file names in our data packages
    do
        create Result.make
        Result.put(42, product_colony_ship)
        Result.put(23, product_automated_factory)
        Result.put(157, product_robo_mining_plant)
        Result.put(50, product_deep_core_mine)
        Result.put(19, product_astro_university)
        Result.put(156, product_research_laboratory)
        Result.put(137, product_supercomputer)
        Result.put(22, product_autolab)
        Result.put(77, product_galactic_cybernet)
        Result.put(88, product_hidroponic_farm)
        Result.put(179, product_subterranean_farms)
        Result.put(199, product_weather_controller)
    end

    get_img(id: INTEGER): IMAGE is
    require
        id >= product_min
    local
        a: FMA_FRAMESET
        sh: SHIP_CONSTRUCTION
    do
        if id > product_max then
            sh ?= colony.producing
            check sh /= Void and sh.design /= Void end
            Result := get_ship_pic(sh.design.owner.color, sh.design.creator.color,
                                   sh.design.size, sh.design.picture, False)
        elseif imgs @ id = Void then
            if id = product_trade_goods then -- Special case for trade goods
                create a.make("client/colony-view/production/prod01.fma")
                imgs.put(a.images @ 1, id)
                Result := imgs @ id
            elseif not filenums.has(id) then
                Result := create {SDL_IMAGE}.make(0, 0)
            else
                create a.make ("client/techs/tech" + (filenums @ id).to_string + ".fma")
                imgs.put(a.images @ 1, id)
                Result := imgs @ id
            end
        else
            Result := imgs @ id
        end
    end
end -- class COLONY_PRODUCING_VIEW
