class ENGAGE_DIALOG

inherit
    FM_DIALOG

create
    make

feature {NONE} -- Creation

    make (f: FLEET; l: PLAYER_LIST [PLAYER]) is
    require
        f /= Void
        f.can_engage
        f.is_in_orbit
        l /= Void
    do
        fleet := f
        enemies := l
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
        Result := k.dk_engage
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
        enemy, orbit: INTEGER
        planet: PLANET
        target: PLAYER
        u: UNSERIALIZER
    do
        create u.start (message)
        u.get_integer
        enemy := u.last_integer
        u.get_integer
        orbit := u.last_integer
        if orbit.in_range (1, fleet.orbit_center.Max_planets) then
            planet := fleet.orbit_center.planet_at (orbit)
        end
        if enemies.has_id (enemy) then
            target := enemies.item_id (enemy)
            fleet.set_engagement (target, planet)
        end
        close
    end
    
feature {NONE} -- Representation

    fleet: FLEET
    
    enemies: PLAYER_LIST [PLAYER]

invariant
    fleet /= Void

end -- class ENGAGE_DIALOG