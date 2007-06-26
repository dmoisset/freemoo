class BUTTON_GROUP
    -- This class (not a widget!) controls a group of groupable buttons.
    -- It's in with the other widgets because it's very related to groupable buttons.

create make

feature {NONE} -- Creation

    make is
        do
            create buttons.make (0, -1)
        end

feature -- Operations

    set_click_handler (handler: PROCEDURE [ANY, TUPLE]) is
            -- Set action to do when any button is clicked.
        do
            click_handler := handler
            buttons.do_all (agent {BUTTON}.set_click_handler (handler))
        end

    add_button (button: BUTTON_IMAGE_GROUPABLE) is
        do
            button.set_click_handler (click_handler)
            button.set_on_enter_handler (agent group_entered)
            button.set_on_exit_handler (agent group_exited)
            buttons.add_last (button)
        end

    clear is
        local
            it: ITERATOR [BUTTON]
        do
            from
                it := buttons.get_new_iterator
            until
                it.is_off
            loop
                it.item.set_click_handler (Void)
                it.item.set_on_enter_handler (Void)
                it.item.set_on_exit_handler (Void)
                it.next
            end
            buttons.clear
        end

feature {NONE} -- Implementation

    click_handler: PROCEDURE [ANY, TUPLE]
        -- Agent to call when any button is clicked

    modifying_state: BOOLEAN
        -- True while we're meddling with our buttons' state.

    buttons: ARRAY [BUTTON_IMAGE_GROUPABLE]

    group_entered is
        do
            if not modifying_state then
                modifying_state := True
                buttons.do_all (agent {BUTTON_IMAGE_GROUPABLE}.set_prelight)
            end
            modifying_state := False
        end

    group_exited is
        do
            if not modifying_state then
                modifying_state := True
                buttons.do_all (agent {BUTTON_IMAGE_GROUPABLE}.set_normal)
            end
            modifying_state := False
        end

end -- class BUTTON_GROUP
