-- See the Copyright notice at the end of this file.
--
class SIGNAL_1[E]
	--
	-- See tutorial/signal/signals.txt for usage
	--

creation {ANY}
	make

feature {}
	callbacks: ARRAY[PROCEDURE[ANY, TUPLE[E]]]

	index, last: INTEGER
			-- work to do while emit is between index and last.

	make is
			-- Initialize new signal object
		do
			create callbacks.make(0, -1)
		ensure
			callbacks.is_empty
		end

feature {ANY}
	connect (p: PROCEDURE[ANY, TUPLE[E]]) is
			-- Connect procedure to be called when signal is emitted
			-- See also last_connect_id
		require
			p /= Void
		do
			callbacks.add_last(p)
		ensure
			not callbacks.is_empty
			last_connect_id = p
		end

	emit (val: E) is
			-- Emit signal, ie. already registred procedure will be called
			-- in registration order except if removed by another before.
		require
			val /= Void
		do
			from
				index := callbacks.lower
				last := callbacks.upper
			until
				index > last
			loop
				callbacks.item(index).call([val])
				index := index + 1
			end
		end

	last_connect_id: PROCEDURE[ANY, TUPLE[E]] is
			-- return identifier on the last connect which may be used
			-- for disconnect (unregister procedure)
		require
			not is_empty
		do
			Result := callbacks.last
		ensure
			Result /= Void
		end

	disconnect (connect_identifier: PROCEDURE[ANY, TUPLE[E]]) is
			-- Unregister procedure for this signal. If the same
			-- procedure was registred many times, only first is removed.
		local
			i: INTEGER
		do
			i := callbacks.fast_index_of(connect_identifier)
			if callbacks.valid_index(i) then
				callbacks.remove(i)
				last := last - 1
				if i <= index then
					index := index - 1
				end
			end
		ensure
			old callbacks.fast_has(connect_identifier) implies callbacks.count = old callbacks.count - 1
			old (not callbacks.fast_has(connect_identifier)) implies callbacks.count = old callbacks.count
		end

	is_empty: BOOLEAN is
			-- return True if no callback is registred for this signal
		do
			Result := callbacks.is_empty
		end

invariant
	callbacks /= Void

end -- class SIGNAL_1
--
-- ------------------------------------------------------------------------------------------------------------------------------
-- Copyright notice below. Please read.
--
-- This file is free software, which comes along with SmartEiffel. This software is distributed in the hope that it will be
-- useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
-- You can modify it as you want, provided this footer is kept unaltered, and a notification of the changes is added.
-- You are allowed to redistribute it and sell it, alone or as a part of another product.
--
-- Copyright(C) 1994-2002: INRIA - LORIA (INRIA Lorraine) - ESIAL U.H.P.       - University of Nancy 1 - FRANCE
-- Copyright(C) 2003-2004: INRIA - LORIA (INRIA Lorraine) - I.U.T. Charlemagne - University of Nancy 2 - FRANCE
--
-- Authors: Dominique COLNET, Philippe RIBET, Cyril ADRIAN, Vincent CROIZIER, Frederic MERIZEN
--
-- http://SmartEiffel.loria.fr - SmartEiffel@loria.fr
-- ------------------------------------------------------------------------------------------------------------------------------
