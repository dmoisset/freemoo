expanded class PKG_USER
    -- Singleton access to PKG_SYSTEM

feature -- Access

    pkg_system: PKG_SYSTEM is
        -- Shared package access object
    once
        !!Result.make_with_paths (<<".">>)
    end

end -- class PKG_USER