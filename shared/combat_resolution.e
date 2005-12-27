class COMBAT_RESOLUTION

create
    make
    
feature -- Creation

    make (plist: PLAYER_LIST [PLAYER]) is
    local
        i: ITERATOR [PLAYER]
    do
        players := plist.count
        create forward.make (1, players)
        create colonized.make (1, players)
        create player_map.make
        from i := plist.get_new_iterator until i.is_off loop
            player_map.add (player_map.count + 1, i.item)
            i.next
        end
        count := 0
        turn := 0
    end

feature -- Operations

    clear is
        -- Clear all combats, preserving player list
    do
        forward.clear_all
    end

    set_colonized_from (s: STAR) is
    local
        i: INTEGER
    do
        colonized.clear_all
        from i := 1 until i > s.Max_planets loop
            if s.planet_at (i) /= Void and then s.planet_at (i).colony /= Void then
                colonized.put (True, player_map @ s.planet_at (i).colony.owner)
            end
            i := i + 1
        end
    end

    add_combat (attacker, defender: PLAYER) is
    require
        has_player (attacker)
        has_player (defender)
        attacker /= defender
    do
        forward.put (player_map @ defender, player_map @ attacker)
        count := count + 1
    end

    remove_combat (attacker: PLAYER) is
    require
        has_player (attacker)
    local
        defender: INTEGER
    do
        defender := forward @ (player_map @ attacker)
        if defender /= 0 then
            count := count - 1
            forward.put (0, player_map @ attacker)
        end
    end

    remove_combats (attackers: ARRAY [PLAYER]) is
    local
        i: INTEGER
    do
        from i := attackers.lower until i > attackers.upper loop
            remove_combat (player_map @ (attackers @ i))
            i := i + 1
        end
    end

    set_turn (t: INTEGER) is
    do
        turn := t \\ forward.count + 1
    end

feature -- Access

    count: INTEGER
        -- Number of unsolved attacks

    players: INTEGER

    has_player (p: PLAYER): BOOLEAN is
    do
        Result := player_map.has (p)
    end

    next_attackers: ARRAY [PLAYER] is
    require
        count > 0
    local
        save: like forward
        attacker: INTEGER
        rslt: ARRAY [INTEGER]
        i: INTEGER
    do
        -- First look for attackers without colonies
        save := forward.twin
        from attacker := forward.lower until attacker > forward.upper loop
            if colonized @ attacker then
                forward.put (0, attacker)
            end
            attacker := attacker + 1
        end
        rslt := next_attackers_simple
        forward := save

        if rslt.count = 0 then
            -- Look for attackers with colonies, then
            rslt := next_attackers_simple
        end

        create Result.make (rslt.lower, rslt.upper)
        from i := Result.lower until i > Result.upper loop
            Result.put (player_map.key_at (rslt @ i), i)
            i := i + 1
        end
    ensure
        Result.count > 0
    end

feature {NONE} -- Implementation

    turn: INTEGER

    forward: ARRAY [INTEGER]

    player_map: HASHED_DICTIONARY [INTEGER, PLAYER]

    next_attackers_simple: ARRAY [INTEGER] is
        -- Next set of attackers, ignoring who has colonies
    local
        defender: INTEGER
        l, u: INTEGER
        i, t: INTEGER
        done: ARRAY [BOOLEAN]
        cycle: ARRAY [INTEGER]
    do
        l := forward.lower
        u := forward.upper
        create Result.make (1, 0)

        -- First, find pure defenders
        from defender := l until defender > u loop
            if has_attacker (defender) and forward @ defender = 0 then
                -- find prioritized attacker
                from
                    t := turn
                until forward @ t = defender loop
                    t := (t \\ forward.count) + 1
                end
                Result.add_last (t)
            end
            defender := defender + 1
        end

        -- Now, find cycles
        create done.make (l, u)
        from defender := l until defender > u loop
            if not (done @ defender) then
                create cycle.make (1, 0)
                from 
                    cycle.add_last (defender)
                until cycle.last = 0 or else forward @ cycle.last = defender loop
                    cycle.add_last (forward @ cycle.last)
                end
                if cycle.last /= 0 then
                    -- We have a cycle, let's find the favorite
                    from
                        t := turn
                    until cycle.has (t) loop
                        t := (t \\ forward.count) + 1
                    end
                    Result.add_last (t)
                    from i := cycle.lower until i > cycle.upper loop
                        done.put (True, cycle @ i)
                        i := i + 1
                    end
                end
            end
            defender := defender + 1
        end
    end

    has_attacker (defender: INTEGER): BOOLEAN is
    local
        attacker: INTEGER
    do
        from attacker := forward.lower until
            Result or attacker > forward.upper
        loop
            Result := forward @ attacker = defender
            attacker := attacker + 1
        end
    end
   
    colonized: ARRAY [BOOLEAN]

end