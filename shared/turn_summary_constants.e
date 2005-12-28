class TURN_SUMMARY_CONSTANTS

feature -- Constants

    event_explored, event_finished_production, event_starvation: INTEGER is unique

    event_min: INTEGER is
    do
        Result := event_explored
    end

    event_max: INTEGER is
    do
        Result := event_starvation
    end

end -- class TURN_SUMMARY_CONSTANTS
