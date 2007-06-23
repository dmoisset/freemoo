class CONSTRUCTION_RECYCLOTRON

inherit
    PERSISTENT_CONSTRUCTION
    rename
        make as construction_make
    redefine
        produce_fixed
    end
    GETTEXT

create
    make

feature

    produce_fixed(c: like colony_type) is
        -- Though our production is proportional to `c''s population,
        -- we produce here to avoid pollution.
    do
        c.industry.add((c.census @ task_industry).to_real, name)
    end

feature {NONE} -- Creation

    make is
    do
        name := l("Recyclotron")
        id := product_recyclotron
        description := no_description
    end

end -- class CONSTRUCTION_RECYCLOTRON
