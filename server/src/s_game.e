class S_GAME

inherit
    GAME
    redefine
        status, players, galaxy, add_player, init_game,
        fleet_type, star_type, planet_type, save
    end
    SERVER_ACCESS
    STORABLE
    redefine dependents
    end

creation
    make_with_options

feature -- Access

    status: S_GAME_STATUS
        -- Status of the game

    players: S_PLAYER_LIST
        -- Players in the game

    galaxy: S_GALAXY

feature -- Operations

    add_player (p: S_PLAYER) is
        -- Add `p' to player list
    do
        players.add (p)
        status.fill_slot
    end
    
    init_game is
    local
        i: ITERATOR [S_PLAYER]
        j: ITERATOR [like star_type]
    do
        -- This feature is public because it must be called when loading a game
        Precursor
        -- Register galaxy
        server.register (galaxy, "galaxy")
        -- Register "scanner", "player" and "new_fleets"
        i := players.get_new_iterator
        from i.start until i.is_off loop
            server.register (galaxy, i.item.id.to_string+":scanner")
	    server.register (galaxy, i.item.id.to_string+":enemy_colonies")
            server.register (galaxy, i.item.id.to_string+":new_fleets")
            server.register (i.item, "player"+i.item.id.to_string)
            i.next
        end
        -- Register stars
        j := galaxy.get_new_iterator_on_stars
        from j.start until j.is_off loop
            server.register (j.item, "star"+j.item.id.to_string)
            j.next
        end
    end

feature {STORAGE} -- Saving

   get_class: STRING is "GAME"
   
   fields: ITERATOR[TUPLE[STRING, ANY]] is
      local
	 a: ARRAY[TUPLE[STRING, ANY]]
      do
	 create a.make(1, 0)
	 a.add_last(["status", status])
	 a.add_last(["players", players])
	 a.add_last(["galaxy", galaxy])
	 Result := a.get_new_iterator
      end
   
   dependents: ITERATOR[STORABLE] is
      local
	 a: ARRAY[STORABLE]
      do
	 create a.make(1, 0)
	 a.add_last(status)
	 a.add_last(players)
	 a.add_last(galaxy)
	 Result := a.get_new_iterator
      end
	
feature {STORAGE} -- Operations - Retrieving
    
    set_primary_keys (elems: ITERATOR [TUPLE [STRING, ANY]]) is
    do
    end
    
    make_from_storage (elems: ITERATOR [TUPLE [STRING, ANY]]) is
    do
	from 
	until elems.is_off
	loop
	    if elems.item.first.is_equal("status") then
		status ?= elems.item.second
	    elseif elems.item.first.is_equal("players") then
		players ?= elems.item.second
	    elseif elems.item.first.is_equal("galaxy") then
		galaxy ?= elems.item.second
	    end
	    elems.next
	end
	if galaxy = Void or players = Void or status = Void then
	    print("game.e:  Called make_from_storage with nonsensical elems!")
	end
    end
    
feature {NONE} -- Operations - Saving
   
   save is
      do
	 save_with_filename("freeMOO_autosave_" + status.date.to_string + ".xml")
      end
   
   save_with_filename(filename: STRING) is
      local
	 st: STORAGE_XML
      do
	 create st.make_with_filename(filename)
	 st.store(Current)
      end
   
feature {NONE} -- Internal
    
    fleet_type: S_FLEET

    star_type: S_STAR
    
    planet_type: S_PLANET
    
end -- class S_GAME
