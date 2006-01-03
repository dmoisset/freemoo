class CONSTRUCTION_SHIELD
-- Radiation shields and other things that keep you from sizzling

inherit
    REPLACEABLE_CONSTRUCTION
    BUILDABLE_CONSTRUCTION
    redefine make end
    GETTEXT

create
    make

feature -- Access

    shield_power: INTEGER
        -- Not used for now

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
        c.constructions.add(Current, id)
    end

    take_down(c: like colony_type) is
    do
        c.location.set_climate(c.preclimate)
        c.constructions.remove(id)
    end

    produce_fixed, produce_proportional, generate_money,
    clean_up_pollution(c: like colony_type) is
    do
    end

feature {NONE} -- Creation

    make(new_name: STRING; new_id: INTEGER) is
    do
        Precursor(new_name, new_id)
        make_replaceable
    end

end -- class CONSTRUCTION_SHIELD
