class C_TURN_SUMMARY_ITEM_EXPLORED

inherit
    TURN_SUMMARY_ITEM_EXPLORED
    redefine get_message end
    CLIENT

create
    make, unserialize_from

feature

    get_message: STRING is
    do
        Result := "Scouts arrived at system " +
                  server.galaxy.star_with_id(star_id).name + "%N"
    end

end -- class C_TURN_SUMMARY_ITEM_EXPLORED
