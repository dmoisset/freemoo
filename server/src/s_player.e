class S_PLAYER

inherit
    PLAYER
    rename
        make as player_make
    undefine
	copy, is_equal
    redefine
        add_to_known_list, colony_type, star_type
    select id end
    STORABLE
    rename
	hash_code as id
    redefine
	dependents, primary_keys, copy, is_equal
    end
    SERVICE
    undefine
	copy, is_equal
    redefine
        subscription_message
    end

creation
    make
    
feature -- Redefined Features
    
    colony_type: S_COLONY
    
    star_type: S_STAR
    
feature {NONE} -- Creation

    make (new_name, new_password: STRING) is
    do
        name := clone (new_name)
        password := clone (new_password)
        player_make
        make_unique_id
    ensure
        name.is_equal (new_name)
        password.is_equal (new_password)
        state = st_setup
    end

feature -- Operations

    set_connection (new_connection: SPP_SERVER_CONNECTION) is
    do
        connection := new_connection
    ensure
        connection = new_connection
    end

    update_clients is
    do
        -- Check to avoid updates on initialization
        if registry /= Void then
            send_message ("player" + id.to_string, subscription_message ("player" + id.to_string))
        end
    end

    serialize_on (s: SERIALIZER2) is
    do
        s.add_tuple (<<id, name, state, color, connection/=Void>>)
    end

feature -- Access

    password: STRING
        -- Player password

    connection: SPP_SERVER_CONNECTION
        -- Conection to client

feature -- Redefined features

    subscription_message (service_id: STRING): STRING is
    local
        serv_id: STRING
        s: SERIALIZER2
        i: ITERATOR [like star_type]
    do
        !!s.make
        -- Validate service_id
        if service_id.has_prefix("player") then
            !!serv_id.copy(service_id)
            serv_id.remove_prefix("player")
            if serv_id.is_integer and then serv_id.to_integer = id then
                s.add_integer (knows_star.count)
                i := knows_star.get_new_iterator
                from i.start until i.is_off loop
                    s.add_integer (i.item.id)
                    i.next
                end
            end
        end
        Result := s.serialized_form
    end

    add_to_known_list (star: like star_type) is
    do
        Precursor (star)
        update_clients
    end

feature -- Operations
    
    copy(other: like Current) is
    do
	standard_copy(other)
	colonies := clone(other.colonies)
	knows_star := clone(other.knows_star)
	has_visited_star := clone(other.has_visited_star)
    end
    
    is_equal(other: like Current): BOOLEAN is
    do
	Result := id = other.id
    end
    
feature {STORAGE} -- Saving

    get_class: STRING is "PLAYER"

    fields: ITERATOR[TUPLE[STRING, ANY]] is
    local
	a: ARRAY[TUPLE[STRING, ANY]]
    do
	create a.make(1, 0)
	a.add_last(["color", color])
	a.add_last(["state", state])
	a.add_last(["sees_all_ships", sees_all_ships])
	a.add_last(["password", password])
	add_to_fields(a, "colony", colonies.get_new_iterator_on_items)
	add_to_fields(a, "knows_star", knows_star.get_new_iterator)
	add_to_fields(a, "has_visited_star", has_visited_star.get_new_iterator)
	Result := a.get_new_iterator
    end
    
    primary_keys: ITERATOR[TUPLE[STRING, ANY]] is
    do
	Result := (<<["id", id],
		     ["name", name]
		     >>).get_new_iterator
    end
        
    dependents: ITERATOR[STORABLE] is
    local
	a: ARRAY[STORABLE]
    do
	create a.make(1, 0)
	add_dependents_to(a, colonies.get_new_iterator_on_items)
	knows_star.do_all(agent a.add_last)
	has_visited_star.do_all(agent a.add_last)
	Result := a.get_new_iterator
    end

feature {STORAGE} -- Retrieving
   
    set_primary_keys (elems: ITERATOR [TUPLE [STRING, ANY]]) is
    local
	i: reference INTEGER
    do
	from
	until elems.is_off loop
	    if elems.item.first.is_equal("id") then
		i ?= elems.item.second
		id := i
	    end
	    if elems.item.first.is_equal("name") then
		name ?= elems.item.second
	    end
	    elems.next
	end
    end
    
feature {STORAGE} -- Retrieving
    
    make_from_storage (elems: ITERATOR [TUPLE [STRING, ANY]]) is
    local
	i: reference INTEGER
	b: reference BOOLEAN
	colony: S_COLONY
	star: S_STAR
    do
	from
	    colonies.clear
	    knows_star.clear
	    has_visited_star.clear
	until elems.is_off loop
	    if elems.item.first.is_equal("password") then
		password ?= elems.item.second
	    elseif elems.item.first.is_equal("color") then
		i ?= elems.item.second
		color := i
	    elseif elems.item.first.is_equal("state") then
		i ?= elems.item.second
		state := i
	    elseif elems.item.first.is_equal("sees_all_ships") then
		b ?= elems.item.second
		sees_all_ships := b
	    elseif elems.item.first.is_equal("id") then
		i ?= elems.item.second
		id := i
	    elseif elems.item.first.has_prefix("colony") then
		colony ?= elems.item.second
		colonies.add (colony, colony.id)
	    elseif elems.item.first.has_prefix("knows_star") then
		star ?= elems.item.second
		knows_star.add(star)
	    elseif elems.item.first.has_prefix("has_visited_star") then
		star ?= elems.item.second
		has_visited_star.add(star)
	    end
	    elems.next
	end
    end

end -- class S_PLAYER
