class C_TURN_SUMMARY_ITEM_RESEARCH

inherit
    TURN_SUMMARY_ITEM_RESEARCH
    redefine get_message end
    TECHNOLOGY_TREE_ACCESS

create
    make, unserialize_from

feature

    get_message: STRING is
    do
        Result := "Your scientists have completed their research in " +
                  tech_tree.tech(tech_id).field.name + "%N"
    end

end -- class C_TURN_SUMMARY_ITEM_RESEARCH
