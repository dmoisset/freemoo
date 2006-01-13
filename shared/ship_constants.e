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
    ship_size_special: INTEGER is 7
        -- size for colony ship, transport, outpost, other special ships

    ship_size_min: INTEGER is do Result := ship_size_frigate end
    ship_size_max: INTEGER is do Result := ship_size_special end

    ship_type_starship: INTEGER is unique
    ship_type_colony_ship: INTEGER is unique
        -- Allowed types for ships.
    
    ship_type_min: INTEGER is do Result := ship_type_starship end
    ship_type_max: INTEGER is do Result := ship_type_colony_ship end

end -- class SHIP_CONSTANTS
