class TRAJECTORY

inherit SDL_LINE_IMAGE

creation
    with_projection

feature {NONE} -- Creation

    with_projection(p1, p2: POSITIONAL; p: PROJECTION) is
    do
        orig := p1
        dest := p2
        my_type := traj_type_normal
        project(p)
        set_dash(dashes@my_type)
    end

feature -- Access

    showx, showy: INTEGER
        -- Position on screen the trajectory should be displayed

feature -- Constants

    traj_type_normal, traj_type_select_ok, traj_type_unreachable,
    traj_type_enemy: INTEGER is UNIQUE;
        -- Types of trajectory, determines color and dash type (use with set_type)

feature -- Operations

    set_type(type: INTEGER) is
    require
        type.in_range(traj_type_normal, traj_type_enemy)
    do
        set_color(rs@type, gs@type, bs@type)
        set_dash(dashes@type)
        my_type := type
    end

    project(p: PROJECTION) is
    local
        xx1, yy1, xx2, yy2: INTEGER
    do
        p.project(orig)
        xx1 := p.x.rounded
        yy1 := p.y.rounded
        p.project(dest)
        xx2 := p.x.rounded
        yy2 := p.y.rounded
        -- Avoid 0 width or height windows:
        if xx1 = xx2 then xx1 := xx2 + 1 end
        if yy1 = yy2 then yy1 := yy2 + 1 end
        
        showx := xx1.min(xx2)
        showy := yy1.min(yy2)
        if xx2 > xx1 then
            xx2 := xx2 - xx1
            xx1 := 0
        else
            xx1 := xx1 - xx2
            xx2 := 0
        end
        if yy2 > yy1 then
            yy2 := yy2 - yy1
            yy1 := 0
        else
            yy1 := yy1 - yy2
            yy2 := 0
        end
        make(xx1, yy1, xx2, yy2, rs@my_type, gs@my_type, bs@my_type)
    end

feature {NONE} -- Representation

    orig, dest: POSITIONAL

    my_type: INTEGER

    rs: ARRAY[INTEGER] is
    once
        Result := <<80, 120, 200, 180>>
        Result.reindex(traj_type_normal)
    end

    gs: ARRAY[INTEGER] is
    once
        Result := <<180, 250, 100, 0>>
        Result.reindex(traj_type_normal)
    end

    bs: ARRAY[INTEGER] is
    once
        Result := <<80, 120, 100, 0>>
        Result.reindex(traj_type_normal)
    end

    dashes: ARRAY[ARRAY[INTEGER]] is
    once
        !!Result.make(traj_type_normal, traj_type_enemy)
        Result.put(create {ARRAY[INTEGER]}.make(0, 1), traj_type_normal)
        Result.item(traj_type_normal).put(1, 0)
        Result.item(traj_type_normal).put(2, 1)
        Result.put(create {ARRAY[INTEGER]}.make(0, 1), traj_type_select_ok)
        Result.item(traj_type_select_ok).put(4, 0)
        Result.item(traj_type_select_ok).put(2, 1)
        Result.put(create {ARRAY[INTEGER]}.make(0, 1), traj_type_unreachable)
        Result.item(traj_type_unreachable).put(2, 0)
        Result.item(traj_type_unreachable).put(5, 1)
        Result.put(create {ARRAY[INTEGER]}.make(0, 1), traj_type_enemy)
        Result.item(traj_type_enemy).put(5, 0)
        Result.item(traj_type_enemy).put(3, 1)
    end

invariant
    my_type.in_range(traj_type_normal, traj_type_enemy)
end -- class TRAJECTORY
