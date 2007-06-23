class TECHNOLOGY_DUMMY
    -- A dummy Technology that doesn't do anything when researched.
    -- Use this for not-yet-implemented technologies.

inherit
    TECHNOLOGY

creation
    make

feature {} -- Creation

    make (new_id: INTEGER) is
        do
            id := new_id
        ensure
            id = new_id
        end

end -- class TECHNOLOGY_DUMMY
