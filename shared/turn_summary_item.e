deferred class TURN_SUMMARY_ITEM

inherit
    TURN_SUMMARY_CONSTANTS

feature -- Access

    kind: INTEGER

    serialize_on(s: SERIALIZER2) is
    deferred
    end

    unserialize_from(u: UNSERIALIZER) is
    deferred
    end

    get_message: STRING is
    do
    end

invariant

    kind.in_range(event_min, event_max)

end -- class TURN_SUMMARY_ITEM
