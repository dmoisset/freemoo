class PKG_SYSTEM

creation
    make_with_paths

feature -- Creation and configuration

    make_with_paths (paths: COLLECTION [STRING]) is
        -- Init with `paths' as package search dirs
        -- Can be used to reconfigure search dirs after creation
    do
        !!path_list.from_collection (paths)
    end

    make_with_config_file (filename: STRING) is
        -- Load path list from `filename'
        -- Empty path list if can not open
    local
        f: TEXT_FILE_READ
        p: STRING
    do
        !!path_list.make
        !!f.connect_to (filename)
        if f.is_connected then
            !!p.make (30)
            from until f.end_of_input loop
                p.clear_count
                f.read_line_in (p)
                p.right_adjust
                if not p.is_equal ("") then
                    path_list.add_last (clone (p))
                end
            end
            f.disconnect
        end
    end

feature -- Access

    last_file_open: TEXT_FILE_READ_EXPORTABLE
        -- Last file opened by `open_file'

feature -- Operations

    open_file (path: STRING) is
        -- Open file at `path'. I successful, store result in `last_file_open'
        -- If not, store Void in `last_file_open'
    require
        path /= Void
    local
        i: ITERATOR [STRING]
        f: TEXT_FILE_READ_EXPORTABLE
    do
        last_file_open := Void
        i := path_list.get_new_iterator
        !!f.make
        from i.start until i.is_off or f.is_connected loop
            f.connect_to (i.item+"/"+path)
            i.next
        end
        if f.is_connected then last_file_open := f end
    ensure
        last_file_open = Void or else last_file_open.is_connected
    end

feature {NONE} -- Internal

    path_list: LINKED_LIST [STRING]
        -- Path were packages are searched

invariant
    path_list /= Void

end -- class PKG_SYSTEM
