class C_FLEET
    -- Fleet, client's view
    -- This model can have incomplete information.

inherit
    FLEET
    redefine make end
    MODEL
    SUBSCRIBER
    CLIENT

creation
    make

feature {NONE} -- Creation

    make is
    do
        Precursor
        make_model
    end

    on_message (msg: STRING; provider: SERVICE_PROVIDER; service: STRING) is
        -- Action when `msg' arrives from `provider''s service `service'
        -- Only `service' expected is "fleet"+id
    local
        i: INTEGER
        s: SERIALIZER
        ir: reference INTEGER
        it: ITERATOR[PLAYER]
        shipcount: INTEGER
        ship: SHIP
    do
        s.unserialize("iiii", msg)
        msg.remove_first(s.used_serial_count)
        ir ?= s.unserialized_form @ 1
        from it := server.player_list.get_new_iterator
        until it.item.id = ir
        loop
            it.next
        end
        owner := it.item
        set_owner(owner)
        ir ?= s.unserialized_form @ 2
        set_eta(ir.item)
        ir ?= s.unserialized_form @ 3
        if eta = 0 then
            if (is_in_orbit) then
                leave_orbit
            end
            i := ir
            enter_orbit (server.galaxy.stars @ i);
            if not (server.galaxy.stars @ i).fleets.has(id) then
					(server.galaxy.stars @ i).fleets.add(Current, id)
					(server.galaxy.stars @ i).notify_views
            end
        else
            set_destination (server.galaxy.stars @ ir)
        end
        ir ?= s.unserialized_form @ 4
        unserialize_from (msg)
	print("Recieved <<" + owner.id.to_string + ", " + eta.to_string + ", " + orbit_center.id.to_string + ", " + ir.to_string + ">>%N")
        ships.clear
        from shipcount := ir until shipcount = 0 loop
            s.unserialize("ii", msg)
            !!ship.make(owner)
            ir ?= s.unserialized_form @ 1
            ship.set_size(ir)
            ir ?= s.unserialized_form @ 2
            ship.set_picture(ir)
            msg.remove_first(s.used_serial_count)
            shipcount := shipcount - 1
            add_ship(ship)
        end
		  notify_views
    end

end -- class C_FLEET
