class POD

feature

    weapon_noweapon, weapon_massdriver, weapon_gausscannon, weapon_lasercannon,
    weapon_particlebeam, weapon_fusionbeam, weapon_ionpulsecannon,
    weapon_gravitonbeam, weapon_neutronblaster, weapon_phasor, weapon_disrupter,
    weapon_deathray, weapon_plasmacannon, weapon_spatialcompressor,
    weapon_nuclearmissile, weapon_merculitemissile, weapon_pulsonmissile,
    weapon_zeonmissile, weapon_antimattertorp, weapon_protontorp,
    weapon_plasmatorp, weapon_nuclearbomb, weapon_fusionbomb, weapon_antimatterbomb,
    weapon_neutroniumbomb, weapon_deathspore, weapon_bioterminator,
    weapon_maulerdevice, weapon_assaultshuttle, weapon_heavyfighter, weapon_bomber,
    weapon_interceptor, weapon_stasisfield, weapon_antimissilerocket,
    weapon_gyrodestabilizer, weapon_plasmaweb, weapon_pulsar,
    weapon_blackholegenerator, weapon_stellarconverter, weapon_tractorbeam,
    weapon_dragonbreath, weapon_phasoreye, weapon_crystalray, weapon_plasmabreath,
    weapon_plasmaflux, weapon_causticslime: INTEGER is unique
        -- Possible values for weapon

    weapon_min: INTEGER is
        -- Minimum value for weapon
    once
        Result := weapon_noweapon
    end

    weapon_max: INTEGER is
        -- Maximum value for weapon
    once
        Result := weapon_causticslime
    end


    angle_forward, angle_forwardext, angle_backward, angle_backwardext,
    angle_360: INTEGER is unique
        -- Possible values for angle

    angle_min: INTEGER is
        -- Minimum value for angle
    once
        Result := angle_forward
    end

    angle_max: INTEGER is
        -- Maximum value for angle
    once
        Result := angle_360
    end


    mod_nomod, mod_heavymount, mod_pointdefense, mod_armorpiercing,
    mod_continuous, mod_norangedissipation, mod_shieldpiercing, mod_autofire,
    mod_enveloping, mod_mirv, mod_eccm, mod_heavilyarmored, mod_fast,
    mod_emisionsguidance, mod_overloaded: INTEGER is unique

    mod_min: INTEGER is
    once
        Result := mod_nomod
    end

    mod_max: INTEGER is
    once
        Result := mod_overloaded
    end

    weapon: INTEGER

    quantity: INTEGER

    ammo: INTEGER

    mods: SET[INTEGER]
        -- Esto se podría hacer con un bitfield!

end -- class POD
