class CONSTRUCTION_SHIELD
-- Radiation shields and other things that keep you from sizzling

inherit
    REPLACEABLE_CONSTRUCTION
    redefine build, take_down end
    GETTEXT

create
    make

feature -- Access

    shield_power: INTEGER
        -- Bombing defense power of this shield.  Not used for now

feature -- Operations

    set_shield_power(power: INTEGER) is
    do
        shield_power := power
    ensure
        shield_power = power
    end

    build(c: like colony_type) is
    do
        c.set_preclimate
        if c.location.climate = c.location.climate_radiated then
            c.location.set_climate(c.location.climate_barren)
        end
        Precursor(c)
    end

    take_down(c: like colony_type) is
    do
        c.location.set_climate(c.preclimate)
        Precursor(c)
    end

end -- class CONSTRUCTION_SHIELD
