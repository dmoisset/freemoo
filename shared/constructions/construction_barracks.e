class CONSTRUCTION_BARRACKS

inherit
    PERSISTENT_CONSTRUCTION
    redefine affect_morale end
    GETTEXT


create make

feature

    affect_morale(c: like colony_type) is
    local
        reason: STRING
    do
        reason := l("No marine barracks")
        c.morale.add(-(c.morale.get_amount_due_to(reason)), reason)
    end

end -- CONSTRUCTION_BARRACKS
