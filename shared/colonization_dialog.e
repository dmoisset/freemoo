class COLONIZATION_DIALOG

inherit
    FM_DIALOG

create
    make_for_fleet, make_for_colony_base

feature {NONE} -- Creation

    make_for_fleet (f: FLEET) is
    require
        f /= Void
        f.can_colonize
        f.is_in_orbit
        f.orbit_center.has_colonizable_planet
    do
        fleet := f
        star := f.orbit_center
        player := f.owner
    end

    make_for_colony_base (c: COLONY) is
    require
        c /= Void
        c.has_colonization_orders
        c.location.orbit_center.has_colonizable_planet
    do
        colony := c
        star := c.location.orbit_center
        player := c.owner
    end

feature -- Access

    player: PLAYER

    kind: INTEGER is
    local
        k: DIALOG_KINDS
    do
        Result := k.dk_colonization
    end

    info: STRING is
    local
        s: SERIALIZER2
    do
        create s.make
        s.add_integer (star.id)
        Result := s.serialized_form
    end

feature -- Operations

    on_message (message: STRING) is
    local
        colonizer: COLONY_SHIP
        orbit: INTEGER
        planet: PLANET
        u: UNSERIALIZER
    do
        create u.start (message)
        u.get_integer
        orbit := u.last_integer
        if orbit.in_range (1, star.Max_planets) then
            planet := star.planet_at (orbit)
            if planet /=  Void and then planet.is_colonizable then
                if fleet /= Void then
                    colonizer := fleet.get_colony_ship
                    colonizer.set_planet_to_colonize (planet)
                else
                    colony.set_planet_to_colonize(planet)
                end
            else
                print ("Invalid colonization request. Ignored%N")
            end
        else
            -- Give refund if this was a colony base
            if colony /= Void then
                player.update_money(100)
            end
        end
        close
    end

feature {NONE} -- Representation

    colony: COLONY

    fleet: FLEET

    star: STAR

invariant

    fleet /= Void xor colony /= Void

end -- class COLONIZATION_DIALOG
