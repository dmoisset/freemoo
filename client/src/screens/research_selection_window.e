class RESEARCH_SELECTION_WINDOW

inherit
    RESEARCH_SELECTION_WINDOW_GUI
    CLIENT

creation
    make

feature -- Operations

    update is
    local
        cat: INTEGER
        next_field: TECH_FIELD
        tech: ITERATOR [TECHNOLOGY]
        i: INTEGER
        r: RECTANGLE
        curr: TECHNOLOGY
    do
        tech_groups.do_all (agent {BUTTON_GROUP}.clear)
        selected_highlight.do_all (agent {WINDOW_IMAGE}.hide)
        from
            cat := category_construction
        until
            cat > category_force_fields
        loop
            next_field := server.player.knowledge.next_field (cat)
            from
                i := 1
                tech := next_field.get_new_iterator
            until
                i > 4 and tech.is_off
            loop
                if i > 4 then
                    print ("Gak!  " + tech.item.name + " doesn't fit!%N")
                else
                    if tech.is_off then
                        tech_labels.item (cat).item (i).set_text ("")
                        tech_buttons.item (cat).item (i).hide
                    else
                        if server.player.knowledge.current_tech /= Void then
                            curr := server.player.knowledge.current_tech
                            if curr = tech.item or (curr.field = tech.item.field and
                               (curr.field.is_general or server.player.race.creative)) then
                                r.set_with_size (left + 15 + (227 * (cat \\ 2)),
                                             30 + (cat // 2) * 105 + 2 * (cat // 6) + 20 * i,
                                             216, 17)
                                selected_highlight.item(i).move (r)
                                selected_highlight.item(i).show
                            end
                        end
                        if next_field.is_general or server.player.race.creative then
                            tech_groups.item (cat).add_button (tech_buttons.item (cat).item (i))
                        end
                        tech_labels.item (cat).item (i).set_text (tech.item.name)
                        tech_buttons.item (cat).item (i).show
                        tech_buttons.item (cat).item (i).set_click_handler (agent set_tech (tech.item))
                        tech.next
                    end
                    i := i + 1
                end
            end
            cat := cat + 1
        end
    end

feature {NONE} -- Callbacks

    set_tech (tech: TECHNOLOGY) is
    do
        server.player.knowledge.set_current_tech (tech) -- Update local state for fast user feedback
        server.set_current_tech (tech) -- Dispatch request to server
        close
    end

end -- class RESEARCH_SELECTION_WINDOW
