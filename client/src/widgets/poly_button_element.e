class POLY_BUTTON_ELEMENT

creation
    make

feature {NONE} -- Creation

    make (new_area: RECTANGLE; new_handler: PROCEDURE [ANY, TUPLE];
          new_image: IMAGE) is
    do
        area := new_area
        handler := new_handler
        image := new_image
    end

feature -- Access

    area: RECTANGLE

    handler: PROCEDURE [ANY, TUPLE]

    image: IMAGE

end -- class POLY_BUTTON_ELEMENT