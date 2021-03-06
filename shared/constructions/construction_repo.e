class CONSTRUCTION_REPO
--
-- This class works as a player's main construction repository.  It has
-- a CONSTRUCTION_BUILDER inside, so it can incorporate new constructions
-- just with their id
--

inherit
    PRODUCTION_CONSTANTS

create
    make

feature {NONE} -- Creation

    make is
    do
        create constructions.make
        create builder
        add_by_id(product_trade_goods)
    end

feature -- Access

    last_added: CONSTRUCTION

    has(id: INTEGER): BOOLEAN is
    do
        Result := constructions.has(id)
    end

    item, infix "@"(id: INTEGER): like last_added is
    do
        if not has(id) then
            add_by_id (id)
            print ("Construction repo:  Requesting " + constructions.at (id).name + ", we don't have it yet.%N")
        end
        Result := constructions @ id
    ensure
        has(id)
    end

    get_new_iterator: ITERATOR[like last_added] is
    do
        Result := constructions.get_new_iterator_on_items
    end

    count: INTEGER is
    do
        Result := constructions.count
    end


feature {NONE} -- Representation

    builder: CONSTRUCTION_BUILDER

    constructions: HASHED_DICTIONARY[like last_added, INTEGER]

feature -- Operations

    add_by_id(id: INTEGER) is
    require
        not has(id)
        id.in_range(product_min, product_max)
    do
        builder.construction_by_id(id)
        last_added := builder.last_built
        constructions.add(builder.last_built, id)
    ensure
        has(id)
    end

    add_starship_design(design: like starship_type) is
    require
        design /= Void
    do
        builder.construction_from_design(design)
        last_added := builder.last_built
        constructions.add(builder.last_built, builder.last_built.id)
    ensure
        has(design.id + product_max)
    end

feature {NONE} -- Anchors

    starship_type: STARSHIP

invariant

    has(product_trade_goods)

end -- class CONSTRUCTION_REPO
