class PLAYER_STATUS_VIEW
    -- Ews view for players status
    
inherit
    VIEW [C_PLAYER_LIST]
    WINDOW
    rename
        make as window_make
    end
    PLAYER_CONSTANTS
    
creation
    make
    
feature -- Creation

    make (w: WINDOW; where: RECTANGLE; new_model: C_PLAYER_LIST) is
        -- build widget as view of `new_model'
    do
        window_make(w, where)
        set_model(new_model)
        on_model_change
    end
    
feature -- Redefined features

    on_model_change is
    local
        dx: INTEGER
        i: ITERATOR[STRING]
        r: RECTANGLE
        cid: INTEGER
    do
        i := model.names.get_new_iterator
        from
            i.start
        until
            i.is_off
        loop
            cid := (model @ i.item).color_id - min_color
            if (model @ i.item).state = st_waiting_turn_end then
                r.set_with_size (dx, 0, 11, 14)
                (window_light @ cid).move (r)
                if not (window_light @ cid).visible then
                    (window_light @ cid).show
                end
                dx := dx + 11
            else
                if (window_light @ cid).visible then
                    (window_light @ cid).hide
                end
            end 
            i.next
        end
        print ("change%N")
    end
    
feature {NONE} -- Implementation

    window_light: ARRAY[WINDOW_ANIMATED] is
    local
        i: INTEGER
    once
        !!Result.make (0, 7)
        from
            i := 0
        until
            i >= 8
        loop
            Result.put (Create {WINDOW_ANIMATED}.make (Current, 0, 0, waiting_light @ i), i)
            (Result @ i).hide
            i := i + 1
        end
    end

    waiting_light : ARRAY[ANIMATION_FMA] is
    local
        i: INTEGER
    once
        !!Result.make (0, 7)
        from
            i := 0
        until
            i >= 8
        loop
            Result.put (Create {ANIMATION_FMA}.make ("client/player-status/light" + i.to_string + ".fma"), i)
            i := i + 1
        end
    end


end -- class PLAYER_STATUS_VIEW