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
        some_tech_selected: BOOLEAN
        r: RECTANGLE
    do
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
                        if server.player.knowledge.current_tech = tech.item then
                            r.set_with_size (left + 15 + (227 * (cat \\ 2)),
                                                30 + (cat // 2) * 105 + 2 * (cat // 6) + 20 * i,
                                                216, 17)
                            selected_highlight.move (r)
                            selected_highlight.show
                            some_tech_selected := True
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
        if not some_tech_selected then
            selected_highlight.hide
        end
    end

feature {NONE} -- Callbacks

    set_tech (tech: TECHNOLOGY) is
    do
        server.player.knowledge.set_current_tech (tech)
        close
    end

end -- class RESEARCH_SELECTION_WINDOW
