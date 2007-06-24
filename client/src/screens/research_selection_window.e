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
                            tech_labels.item (cat).item (i).set_text (tech.item.name)
                            tech_buttons.item (cat).item (i).show
                            tech.next
                        end
                        i := i + 1
                    end
                end
                cat := cat + 1
            end
        end

end -- class RESEARCH_SELECTION_WINDOW
