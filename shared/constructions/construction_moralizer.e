class CONSTRUCTION_MORALIZER

inherit
    PERSISTENT_CONSTRUCTION
    redefine affect_morale end

create
    make

feature

    affect_morale(c: like colony_type) is
    do
        c.morale.add(morale_effect, name)
    end

feature -- Configuration

    set_morale(morale: INTEGER) is
    do
        morale_effect := morale
    end

feature {NONE} -- Representation

    morale_effect: INTEGER

end -- class CONSTRUCTION_MORALIZER
