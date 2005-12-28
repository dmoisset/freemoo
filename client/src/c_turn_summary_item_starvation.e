class C_TURN_SUMMARY_ITEM_STARVATION

inherit
    TURN_SUMMARY_ITEM_STARVATION
    redefine get_message end
    CLIENT

create
    make, unserialize_from

feature

    get_message: STRING is
    do
        Result := "Colony " +
                  server.player.colonies.at(colony_id).location.name +
                  " suffered starvation (short "
        if food > 0 then
            Result := Result + food.to_string + " food"
        end
        if food > 0 and industry > 0 then
            Result := Result + " and "
        end
        if industry > 0 then
            Result := Result + industry.to_string + "industry"
        end
        Result := Result + ")%N"
    end

end -- class C_TURN_SUMMARY_ITEM_STARVATION
