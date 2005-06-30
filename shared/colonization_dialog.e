class COLONIZATION_DIALOG

inherit
    FM_DIALOG

create
    make

feature {NONE} -- Creation

    make (f: FLEET) is
    require
        f /= Void
        f.can_colonize
        f.is_in_orbit
        f.orbit_center.has_colonizable_planet
    do
        fleet := f
    end

feature -- Access

    player: PLAYER is
    do
        Result := fleet.owner
    end

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
        s.add_integer (fleet.id)
        Result := s.serialized_form
    end

feature -- Operations

    on_message (message: STRING) is
    local
        colonizer: COLONY_SHIP
        orbit: INTEGER
        u: UNSERIALIZER
    do
        create u.start (message)
        u.get_integer
        orbit := u.last_integer
        if orbit.in_range (1, fleet.orbit_center.Max_planets) then
            colonizer := fleet.get_colony_ship
            colonizer.set_will_colonize (fleet.orbit_center.planet_at (orbit))
        end
        close
    end
    
feature {NONE} -- Representation

    fleet: FLEET

invariant
    fleet /= Void
end -- class COLONIZATION_DIALOG