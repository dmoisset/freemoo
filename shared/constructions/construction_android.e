class CONSTRUCTION_ANDROID

inherit
    CONSTRUCTION
    redefine
        can_be_built_on, cost, build
    end

create
    make

feature

    can_be_built_on(c: like colony_type): BOOLEAN is
    do
        Result := True
    end

    build (c: like colony_type) is
    do
        check xeno_repository.androids /= Void end
        create populator.make(xeno_repository.androids, c)
        populator.set_is_android(True)
        populator.set_single_task(task)
        if populator.fits_on(c) then
            c.receive(populator)
        else
            print("Discarded android as it doesn't fit!%N")
        end
    end

    cost(c: like colony_type): INTEGER is
    do
        Result := 50
    end

    set_task(new_task: INTEGER) is
    require
        new_task.in_range(task_farming, task_science)
    do
        task := new_task
    ensure
        task = new_task
    end

feature {NONE} -- Implementation

    task: INTEGER

    xeno_repository: XENO_REPOSITORY is
    do
    end

feature {NONE} -- Anchors

    populator: POPULATION_UNIT

end -- class CONSTRUCTION_ANDROID
