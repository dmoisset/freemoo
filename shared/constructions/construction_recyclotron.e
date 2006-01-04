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
        c.industry.add(c.census @ task_industry, name)
    end

feature {NONE} -- Creation

    make is
    do
        name := l("Recyclotron")
        id := product_recyclotron
        description := l("Allows scrap material reuse, reducing construction costs. Every unit of population generates +1 production. This increase does not count toward the planetary pollution level.")
    end

end -- class CONSTRUCTION_RECYCLOTRON
