class S_STAR

inherit
    STAR
    SERVICE
        redefine subscription_message

feature
    subscription_message(service_id:STRING): STRING is
    local
        s: SERIALIZER
        i: ITERATOR [PLANET]
    do
        !!Result.make (0)
        s.serialize ("si", <<name, planets.count>>)
        Result.append (s.serialized_form)
        from
            i := planets.get_new_iterator
        until i.is_off loop
            s.serialize ("iiiiii", <<i.item.size, i.item.climate, i.item.mineral,
                     i.item.gravity, i.item.special, i.item.orbit>>)
            Result.append (s.serialized_form)
            i.next
        end
    end

end -- class S_STAR
