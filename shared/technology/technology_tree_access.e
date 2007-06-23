class TECHNOLOGY_TREE_ACCESS
    -- Mixin class for accessing the singleton technology tree

feature {} -- If you need it, inherit it yourself!

    tech_tree: TECHNOLOGY_TREE is
    once
        create Result.make
    end

end -- class TECHNOLOGY_TREE_ACCESS
