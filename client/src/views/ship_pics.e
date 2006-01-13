class SHIP_PICS
    -- Can provide a picture for a ship

inherit
    PLAYER_CONSTANTS
    SHIP_CONSTANTS

feature {NONE} -- Representation

    ship_pics: ARRAY2[ARRAY2[ARRAY[IMAGE]]] is
        -- Container for ship pics.  Don't access directly; fetch 
        -- images with `get_ship_pic'.
    once
        !!Result.make(min_color, max_color,
                      min_color, max_color) -- Creator and owner
    end

feature -- Access

    cursor: ARRAY[IMAGE] is
    local
        i: IMAGE_FMI
    once
        !!Result.make(1, 2)
        create i.make_from_file ("client/fleet-view/cursor.fmi")
        Result.put(i, 2)
        Result.put(create {SDL_IMAGE}.make_transparent(i.width, i.height), 1)
    end

    get_ship_pic(owner, creator, size, pic: INTEGER; highlight: BOOLEAN): IMAGE is
        -- Gets a ship image from `ship_pics', checking first to see if 
        -- it has already been loaded.
    require
        owner.in_range(min_color, max_color)
        creator.in_range(min_color, max_color)
        size.in_range(ship_size_min, ship_size_max)
        pic.in_range(0, 7)
    local
        a: FMA_FRAMESET
        imgs: ARRAY [IMAGE]
        xoffset, yoffset: INTEGER
        ship_and_cursor: IMAGE_COMPOSITE
    do
        if ship_pics.item(owner, creator) = Void then
            ship_pics.put(create {ARRAY2[ARRAY[IMAGE]]}.make(ship_size_min, ship_size_max, 0, 7), owner, creator)
        end
        if ship_pics.item(owner, creator).item(size, pic) = Void then
            !!imgs.make (1, 2)
            ship_pics.item(owner, creator).put(imgs, size, pic)
            !!a.make("client/fleet-view/ships/ship" +
                     (creator - min_color).to_string +
                     size.to_string +
                     pic.to_string +
                     (owner - min_color).to_string + ".fma")
            xoffset := a.positions.item (1).x
            yoffset := a.positions.item (1).y
            imgs.put(create {IMAGE_OFFSET}.make (a.images @ 1,
                                                 xoffset, yoffset),
                     1)
            create ship_and_cursor.make (cursor.item(1).width, cursor.item(1).height)
            ship_and_cursor.add (a.images.item(1), xoffset, yoffset)
            ship_and_cursor.add (cursor.item(2), 0, 0)
            imgs.put(ship_and_cursor, 2)
        end
        if highlight then
            result := ship_pics.item(owner, creator).item(size, pic).item(2)
        else
            result := ship_pics.item(owner, creator).item(size, pic).item(1)
        end

    end

end -- class SHIP_PICS
