class GETTEXT

feature -- Access

    l, localize (s: STRING): STRING is
        -- Localized version of `s'
    do
        Result := s
    end

end -- class GETTEXT