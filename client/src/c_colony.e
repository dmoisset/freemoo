class C_COLONY
	
inherit
	COLONY	
	SUBSCRIBER
	
creation
	make
	
feature
	
    on_message (msg: STRING; provider: SERVICE_PROVIDER; service: STRING) is
        -- Action when `msg' arrives from `provider''s `service'
    local
        s: UNSERIALIZER
    do
        !!s.start (msg)
		s.get_integer
		producing := s.last_integer + product_min
	end
	
end -- class C_COLONY
	
