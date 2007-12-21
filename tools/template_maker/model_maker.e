class MODEL_MAKER

inherit
	PACKAGE_MAKER
		redefine make end
	SDL_SURFACE -- To be able to poke around with other SDL_SURFACEs' innards
		rename
			make as sdl_surface_make
		end
creation make

feature {} -- Creation

	make is
		do
			-- Somebody made it that you can't create SDL_SURFACES without having set a video mode
			set_videomode (1, 1, 24, False)
			dont_release_flag := True
			Precursor
		end

feature -- Concrete features

	do_initial_stuff is
		do
		end

	do_final_stuff is
		do
		end

	do_stuff_with_folder (prefixdir, foldername: STRING) is
		do
			create_directory (datadir + "/" + prefixdir + "/" + foldername)
		end

	do_stuff_with_fma (fma: FMA_FRAMESET; prefixdir, fmaname: STRING) is
		local
			j: INTEGER
			out_filename: STRING
			sdl_image: SDL_IMAGE
		do
			from
				j := fma.images.lower
			until
				j > fma.images.upper
			loop
				out_filename := datadir + "/" + prefixdir + "/" + fmaname.substring (1, fmaname.count - 4) + "." + j.out
				sdl_image ?= fma.images.item(j)
				check sdl_image /= Void end
				save_as_png (sdl_image, out_filename)
				j := j + 1
			end
		end

	do_stuff_with_fmi (fmi: IMAGE_FMI; prefixdir, fminame: STRING) is
		local
			out_filename: STRING
		do
			out_filename := datadir + "/" + prefixdir + "/" + fminame.substring (1, fminame.count - 4)
			save_as_png (fmi, out_filename)
		end

feature -- Auxiliar

	save_as_png (img: SDL_IMAGE; filename: STRING) is
		local
			sys: SYSTEM
			surface: SDL_SURFACE
			r: RECTANGLE
			ft: FILE_TOOLS
		do
			r.set_with_size (0, 0, img.width, img.height)
			create surface.make (img.width, img.height)
			surface.fillrect (r, surface.get_color (0, 255, 255))
			img.blit (surface, 0, 0, r)
			sdl_save_bmp (surface.to_external, (filename + ".bmp").to_external)
			sys.execute_command_line ("convert " + filename + ".bmp -transparent cyan " + filename + ".png")
			ft.delete (filename + ".bmp")
		end

	sdl_save_bmp (surface, filename: POINTER) is
		external "C use <SDL/SDL.h>"
		alias "SDL_SaveBMP"
		end

end -- class MODEL_MAKER
