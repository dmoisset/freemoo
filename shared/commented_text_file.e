class COMMENTED_TEXT_FILE

creation
    make

feature {NONE} -- Creation

    make (str: INPUT_STREAM) is
    require
        str /= Void
        str.is_connected
    do
        stream := str
        !!last_line.make (50)
    ensure
        stream = str
    end

feature -- Operations

    read_line is
    local
        c: INTEGER
    do
        if stream.end_of_input then
            last_line := Void
        else
            last_line.clear
            stream.read_line_in (last_line)
            c := last_line.first_index_of ('#')
            if c/=0 then
                last_line.resize (c-1)
            end
        end
    end

    read_nonempty_line is
    do
        from
            read_line
        until last_line = Void or else not last_line.is_empty loop
            read_line
        end
    end

feature -- Access

    last_line: STRING

feature {NONE} -- Representation

    stream: INPUT_STREAM

invariant
    stream.is_connected

end -- class COMMENTED_TEXT_FILE