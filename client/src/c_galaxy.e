class C_GALAXY
    -- Galactic map (client view)
    -- This model can have incomplete information, because server only sends
    -- what the player at the client should know.

inherit
    CLIENT
    GALAXY
        redefine make, stars, set_stars, fleets, add_fleet end
    MODEL
        redefine notify_views end
    VIEW [C_STAR]
        rename on_model_change as on_star_change end
    VIEW [C_FLEET]
        rename on_model_change as on_fleet_change end
    SUBSCRIBER

creation
    make

feature {NONE} -- Creation

    make is
    do
        Precursor
        make_model
    end

feature {SERVICE_PROVIDER} -- Subscriber callback

    on_message (msg: STRING; provider: SERVICE_PROVIDER; service: STRING) is
        -- Action whe `msg' arrives from `provider''s `service'
        -- Regenerates everything from scratch.  There must be a better way...
        -- Also, depend on stars not moving around in the array.
    do
        if service.is_equal("galaxy") then
            unpack_galaxy_message(msg)
        elseif service.has_suffix(":scanner") then
            unpack_scanner_message(msg)
        elseif service.has_suffix(":new_fleets") then
            unpack_new_fleets_message(msg)
        else
            check unexpected_message: False end
        end
    end

    unpack_galaxy_message (msg: STRING)is
    local
        new_stars: DICTIONARY[C_STAR, INTEGER]
        newmsg: STRING
        ir: reference INTEGER
        id, count: INTEGER
        s: SERIALIZER
        star: C_STAR
    do
        limit.unserialize_from(msg)
        s.unserialize("i", msg)
        ir ?= s.unserialized_form @ 1
        count := ir
        newmsg := msg
        newmsg.remove_first(s.used_serial_count)
        !!new_stars.make
        from until count = 0 loop
            s.unserialize("iii", newmsg)
            newmsg.remove_first(s.used_serial_count)
            ir ?= s.unserialized_form @ 1
            id := ir
            if stars.has(id) then
                star ?= stars @ id
            else
                !!star.make_defaults
                star.add_view (Current)
                star.set_id (id)
            end
            ir ?= s.unserialized_form @ 2
-- Using .item below because of SE bug #152
            star.set_kind(ir.item + star.kind_min)
            ir ?= s.unserialized_form @ 3
            star.set_size(ir.item + star.stsize_min)
            star.unserialize_from (newmsg)
            new_stars.add(star, id)
            count := count - 1
        end
        set_stars (new_stars)
        notify_views
    end

    unpack_scanner_message(msg:STRING) is
    local
        new_fleets: DICTIONARY[C_FLEET, INTEGER]
        newmsg: STRING
        ir: INTEGER_REF
        count, shipcount: INTEGER
        s: SERIALIZER
        owner: PLAYER
        fleet: C_FLEET
        ship: SHIP
        it: ITERATOR[PLAYER]
        star_it: ITERATOR[STAR]
    do
        from star_it := stars.get_new_iterator_on_items
        until star_it.is_off
        loop
            star_it.item.fleets.clear
            star_it.next
        end
        s.unserialize("i", msg)
        ir ?= s.unserialized_form @ 1
        count := ir.item
        !!new_fleets.make
        if count > 0 then
            newmsg := msg.substring(s.used_serial_count + 1, msg.count)
            from until count = 0 loop
                !!fleet.make
                s.unserialize("iiii", newmsg)
                newmsg.remove_first(s.used_serial_count)
                ir ?= s.unserialized_form @ 1
                from it := server.player_list.get_new_iterator
                until it.item.id = ir.item
                loop
                    it.next
                end
                owner := it.item
                fleet.set_owner(owner)
                ir ?= s.unserialized_form @ 2
                fleet.set_eta(ir.item)
                ir ?= s.unserialized_form @ 3
                if fleet.eta = 0 then
                    fleet.enter_orbit (stars @ ir.item);
--These don't work >:G #!?!
--                    stars.item(ir.item).fleets.add(fleet, fleet.id)
--                    (stars.item(ir.item)).fleets.add(fleet, fleet.id)
                    (stars @ ir.item).fleets.add(fleet, fleet.id)
                else
                    fleet.set_destination (stars @ ir.item)
                end
                fleet.unserialize_from (newmsg)
                new_fleets.add(fleet, fleet.id)
                ir ?= s.unserialized_form @ 4
	print("Recieved <<" + fleet.owner.id.to_string + ", " + fleet.eta.to_string + ", " + fleet.orbit_center.id.to_string + ", " + ir.item.to_string + ">>%N")
                from shipcount := ir.item until shipcount = 0 loop
                    s.unserialize("ii", newmsg)
                    !!ship.make
                    ir ?= s.unserialized_form @ 1
                    ship.set_size(ir.item)
                    ir ?= s.unserialized_form @ 2
                    ship.set_picture(ir.item)
                    newmsg.remove_first(s.used_serial_count)
                    shipcount := shipcount - 1
                    fleet.add_ship(ship)
                end
                count := count - 1
            end
        end
        check new_fleets /= Void end
        fleets := new_fleets
        notify_views
    end

    unpack_new_fleets_message(msg: STRING) is
    local
        remainder: STRING
        s: SERIALIZER
        ir: INTEGER_REF
        i: INTEGER
        fleet: C_FLEET
    do
        !!remainder.copy(msg)
        s.unserialize("i", remainder)
        remainder.remove_first(s.used_serial_count)
        ir ?= s.unserialized_form @ 1
        from i := ir.item
        until i = 0 loop
            s.unserialize("i", remainder)
            ir ?= s.unserialized_form @ 1
            !!fleet.make
            fleet.add_view(Current)
            fleet.set_owner(server.player)
            fleet.set_id(ir.item)
            add_fleet(fleet)
            i := i - 1
        end
    end

feature -- Redefined features

    stars: DICTIONARY [C_STAR, INTEGER]

    fleets: DICTIONARY [C_FLEET, INTEGER]

    set_stars (starlist: DICTIONARY [C_STAR, INTEGER]) is
    require
        starlist /= Void
    do
        stars := starlist
        changed_starlist := True
        notify_views
    end

    add_fleet(new_fleet: C_FLEET) is
    do
        fleets.add(new_fleet, new_fleet.id)
        if new_fleet.orbit_center /= Void then
            new_fleet.orbit_center.fleets.add(new_fleet, new_fleet.id)
        end
        server.subscribe(new_fleet, "fleet" + new_fleet.id.to_string)
    end

feature -- Redefined features

    on_star_change is
        -- Stars changed
    do
        changed_stardata := True
        notify_views
    end

    on_fleet_change is
        -- Stars changed
    do
--        crash
        changed_starlist := True
        changed_stardata := True
        notify_views
    end

feature -- Notification

    changed_starlist: BOOLEAN

    changed_stardata: BOOLEAN

    notify_views is
    do
        Precursor
        changed_starlist := False
        changed_stardata := False
    end

end -- class C_GALAXY