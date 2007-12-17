class TEMPLATE_MAKER

inherit PACKAGE_MAKER

creation make

feature -- Concrete features

	do_initial_stuff is
		do
			create packfile.connect_to (datadir + "/" + packfilename)
			packfile.put_string ("#!/bin/bash%N")
			packfile.put_string ("mkdir " + packeddir + "%N")
		end

	do_final_stuff is
		do
			packfile.disconnect
		end

	do_stuff_with_folder (prefixdir, foldername: STRING) is
		do
			packfile.put_string ("mkdir " + packeddir + "/" + prefixdir + "/" + foldername + "%N")
		end

	do_stuff_with_fma (fma: FMA_FRAMESET; prefixdir, fmaname: STRING) is
		local
			j: INTEGER
			pointsize: INTEGER
			out_filename: STRING
			fmi2fma: STRING
			sys: SYSTEM
		do
			fmi2fma := "fmi2fma"
			from
				j := fma.images.lower
			until
				j > fma.images.upper
			loop
				if fma.width > 50 then
					pointsize := 10
				else
					pointsize := 8
				end
				out_filename := prefixdir + "/" + fmaname.substring (1, fmaname.count - 4) + "." + j.to_string
				sys.execute_command_line ("convert -size " + fma.width.to_string + "x" + fma.height.to_string +
				                          " xc:black -font Helvetica -pointsize " + pointsize.out +
				                          " -fill white -draw %"text 5,8 '" + fmaname + "'%" -border 1x1 " + datadir +
				                          "/" + srcdir + "/" + out_filename + ".png")
				packfile.put_string ("png2fmi -r " + srcdir + "/" + out_filename + ".png " + srcdir + "/" + out_filename + ".fmi%N")
				fmi2fma := fmi2fma + " " + srcdir + "/" + out_filename + ".fmi"
				j := j + 1
			end
			out_filename := packeddir + "/" + prefixdir + "/" + fmaname.substring (1, fmaname.count - 4) + ".fma"
			packfile.put_string (fmi2fma + " " + out_filename + "%N")
		end

	do_stuff_with_fmi (fmi: IMAGE_FMI; prefixdir, fminame: STRING) is
		local
			pointsize: INTEGER
			out_filename: STRING
			sys: SYSTEM
		do
			if fmi.width > 50 then
				pointsize := 10
			else
				pointsize := 8
			end
			out_filename := prefixdir + "/" + fminame.substring (1, fminame.count - 4)
			sys.execute_command_line ("convert -size " + fmi.width.to_string + "x" + fmi.height.to_string + " xc:black -font Helvetica -pointsize " + pointsize.out + " -fill white -draw %"text 5,8 '" + fminame + "'%" -border 1x1 " + datadir + "/" + srcdir + "/" + prefixdir + "/" + fminame.substring (1, fminame.count - 4) + ".png")
			packfile.put_string ("png2fmi -r " + srcdir + "/" + out_filename + ".png " + packeddir + "/" + out_filename + ".fmi%N")
		end

feature -- Auxiliar

	packfile: TEXT_FILE_WRITE

feature -- Constants

	packeddir: STRING is "packed"

	packfilename: STRING is "template.pack.sh"

end -- class TEMPLATE_MAKER
