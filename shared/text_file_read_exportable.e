class TEXT_FILE_READ_EXPORTABLE

inherit
    TEXT_FILE_READ

creation
    make, connect_to

feature -- Access

    to_external: POINTER is
        -- FILE * associated to this file
    do
        Result := input_stream
    end

end