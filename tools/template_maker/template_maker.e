class TEMPLATE_MAKER

inherit
	ARGUMENTS

creation make

feature

	exit_with_message is
		do
			print ("Usage: " + argument (0) + " <indir>%N")
			print ("%T<indir> is the directory that contains all fma's and fmi's to pack%N")
			print ("%T./" + datadir + "/ must not exist, and will be created%N")
			die_with_code (exit_failure_code)
		end

	make is
		local
			indir: DIRECTORY
			info: FILE_TOOLS
		do
			if argument_count /= 1 then
				exit_with_message
			end
			if info.is_readable (datadir) then
				exit_with_message
			end
			create indir.scan (argument (1))
			if indir.last_scan_status then
				create_directory (datadir)
				create_directory (datadir + "/" + srcdir)
				create logfile.connect_to (datadir + "/" + logfilename)
				create packfile.connect_to (datadir + "/" + packfilename)
				packfile.put_string ("#!/bin/bash%N")
				packfile.put_string ("mkdir " + packeddir + "%N")
				scan (indir, "")
			end
			logfile.disconnect
			packfile.disconnect
		end

feature {}

	create_directory (name: STRING) is
		local
			dir_creator: BASIC_DIRECTORY
		do
			if not dir_creator.create_new_directory (name) then
				print (argument(0) + ": Unable to create directory " + name + "%N")
				exit_with_message
			end
		end


	scan (dir: DIRECTORY; outdir: STRING) is
		require
			dir.last_scan_status
		local
			subdir: DIRECTORY
			i, j, pointsize: INTEGER
			fma: FMA_FRAMESET
			fmi: IMAGE_FMI
			sys: SYSTEM
			msg, fmi2fma, out_filename, in_filename: STRING
		do
			from
				i := dir.lower
			until
				i > dir.upper
			loop
				if not dir.item (i).has_prefix (".") then
					in_filename := dir.path + "/" + dir.item (i)
					create subdir.scan (in_filename)
					if dir.item (i).is_equal ("CVS") then
						msg := "Skipping " + in_filename + "%N"
						logfile.put_string (msg)
						print (msg)
					elseif subdir.last_scan_status then
						create_directory (datadir + "/" + srcdir + "/" + outdir + "/" + dir.item (i))
						packfile.put_string ("mkdir " + packeddir + "/" + outdir + "/" + dir.item (i) + "%N")
						scan (subdir, outdir + "/" + dir.item (i))
					elseif dir.item (i).has_suffix (".fma") then
						create fma.make (dir.path + "/" + dir.item (i))
						msg := in_filename + ": size="+fma.width.to_string+"x"+fma.height.to_string+" count=" + fma.images.count.out + "%N"
						logfile.put_string (msg)
						fmi2fma := "fmi2fma"
						print (msg)
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
							out_filename := outdir + "/" + dir.item (i).substring (1, dir.item (i).count - 4) + "." + j.to_string
							sys.execute_command_line ("convert -size " + fma.width.to_string + "x" + fma.height.to_string + " xc:black -font Helvetica -pointsize " + pointsize.out + " -fill white -draw %"text 5,8 '" + dir.item (i) + "'%" -border 1x1 " + datadir + "/" + srcdir + "/" + out_filename + ".png")
							packfile.put_string ("png2fmi -r " + srcdir + "/" + out_filename + ".png " + srcdir + "/" + out_filename + ".fmi%N")
							fmi2fma := fmi2fma + " " + srcdir + "/" + out_filename + ".fmi"
							j := j + 1
						end
						out_filename := packeddir + "/" + outdir + "/" + dir.item (i).substring (1, dir.item (i).count - 4) + ".fma"
						packfile.put_string (fmi2fma + " " + out_filename + "%N")
					elseif dir.item (i).has_suffix (".fmi") then
						create fmi.make_from_file (dir.path + "/" + dir.item (i))
						if fmi.width > 50 then
							pointsize := 10
						else
							pointsize := 8
						end
						msg := dir.path + "/"  + dir.item (i) + ": size="+fmi.width.to_string+"x"+fmi.height.to_string+"%N"
						logfile.put_string (msg)
						print (msg)
						out_filename := outdir + "/" + dir.item (i).substring (1, dir.item (i).count - 4)
						sys.execute_command_line ("convert -size " + fmi.width.to_string + "x" + fmi.height.to_string + " xc:black -font Helvetica -pointsize " + pointsize.out + " -fill white -draw %"text 5,8 '" + dir.item (i) + "'%" -border 1x1 " + datadir + "/" + srcdir + "/" + outdir + "/" + dir.item (i).substring (1, dir.item (i).count - 4) + ".png")
						packfile.put_string ("png2fmi -r " + srcdir + "/" + out_filename + ".png " + packeddir + "/" + out_filename + ".fmi%N")
					end
				end
				i := i + 1
			end
		end

	logfile: TEXT_FILE_WRITE

	packfile: TEXT_FILE_WRITE

feature -- Constants

	datadir: STRING is "data"

	srcdir: STRING is "src"

	packeddir: STRING is "packed"

	logfilename: STRING is "template.log"

	packfilename: STRING is "template.pack.sh"

end -- class TEMPLATE_MAKER
