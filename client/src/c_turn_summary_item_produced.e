class C_TURN_SUMMARY_ITEM_PRODUCED

inherit
    TURN_SUMMARY_ITEM_PRODUCED
    redefine get_message end
    CLIENT

create
    make, unserialize_from

feature

    get_message: STRING is
    do
        Result := "Colony " +
                  server.player.colonies.at(colony_id).location.name +
                  " finished producing " + name + "%N"
    end

end -- class C_TURN_SUMMARY_ITEM_PRODUCED
