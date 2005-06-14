class SETUP_WINDOW

inherit
    SETUP_WINDOW_GUI
    redefine handle_event end
    CLIENT
    GETTEXT
    STRING_FORMATTER
    PLAYER_CONSTANTS

creation
    make

feature -- Operations

    activate is
    require
        server /= Void and not server.is_closed
        server.player_name /= Void
        server.player /= Void
    do
--        setup_window.set_title (format(l("Player setup for ~1~"),
--                                     <<server.player_name>>))
        show
        ruler_name.grab
    end

feature -- Redefined features

    handle_event (event:EVENT) is
    local
        n: EVENT_NETWORK
    do
        Precursor (event)
        n ?= event
        if n /= Void then
            on_network_event
        end
    end

feature {NONE} -- Callbacks

    start_game is
    do
        server.set_ready
    end

    disconnect is
    do
        server.close
        destroy
    end

    destroy is
        -- Close and hide window
    do
        hide
--        flag_viewer.widget.hide
    end

    on_network_event is
        -- Check network
    do
        if server.is_closed or not server.has_joined or server.game_status.started then
            destroy
        end
    end

feature {NONE} -- Custom widgets

    new_player_list (where: RECTANGLE) is
    do
        !!player_list.make (Current, where, server.player_list)
    end
    
    
    new_radiogroups(races_where, color_where: RECTANGLE) is
    local
		ratts: RACE_ATTRIBUTES
    	bup, bdown: IMAGE_FMI
		it: ITERATOR[STRING]
    do
		create ratts.make
		create bup.make_from_file("client/setup-window/radio-button-u.fmi")
		create bdown.make_from_file("client/setup-window/radio-button-d.fmi")
		
		create race_name_group.make(Current, races_where, bup, bdown)
		from it := ratts.race_names.get_new_iterator
		until it.is_off loop
			race_name_group.add_option(it.item)
			it.next
		end
		race_name_group.add_option("Custom")
		
		create color_group.make(Current, color_where, bup, bdown)
		from it := server.color_names.get_new_iterator_on_items
		until it.is_off loop
			color_group.add_option(it.item)
			it.next
		end
    end
	
end -- class SETUP_WINDOW
