class SHIP_CONSTANTS
    -- Useful constants for talking about SHIPs

feature
    ship_size_frigate: INTEGER is 1
    ship_size_destroyer: INTEGER is 2
    ship_size_cruiser: INTEGER is 3
    ship_size_battleship: INTEGER is 4
    ship_size_titan: INTEGER is 5
    ship_size_doomstar: INTEGER is 6
        -- Allowed sizes for ships, *shouldn't* be changed for unique values

    ship_size_min: INTEGER is do Result := ship_size_frigate end
    ship_size_max: INTEGER is do Result := ship_size_doomstar end

end -- class SHIP_CONSTANTS
