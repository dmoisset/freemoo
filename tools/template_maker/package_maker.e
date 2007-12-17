deferred class PACKAGE_MAKER

inherit
	ARGUMENTS

feature {} -- Creation

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
				do_initial_stuff
				scan (indir, "")
			end
			logfile.disconnect
			do_final_stuff
		end

feature -- Features that our children should implement

	do_initial_stuff is
		deferred
		end

	do_final_stuff is
		deferred
		end

	do_stuff_with_folder (prefixdir, foldername: STRING) is
		deferred
		end

	do_stuff_with_fma (fma: FMA_FRAMESET; prefixdir, fmaname: STRING) is
		deferred
		end

	do_stuff_with_fmi (fmi: IMAGE_FMI; prefixdir, fminame: STRING) is
		deferred
		end

feature -- Auxiliar

	logfile: TEXT_FILE_WRITE

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
			i: INTEGER
			fma: FMA_FRAMESET
			fmi: IMAGE_FMI
			msg, in_filename: STRING
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
						do_stuff_with_folder (outdir, dir.item (i))
						scan (subdir, outdir + "/" + dir.item (i))
					elseif dir.item (i).has_suffix (".fma") then
						create fma.make (dir.path + "/" + dir.item (i))
						msg := in_filename + ": size="+fma.width.to_string+"x"+fma.height.to_string+" count=" + fma.images.count.out + "%N"
						logfile.put_string (msg)
						print (msg)
						do_stuff_with_fma (fma, outdir, dir.item (i))
					elseif dir.item (i).has_suffix (".fmi") then
						create fmi.make_from_file (dir.path + "/" + dir.item (i))
						msg := dir.path + "/"  + dir.item (i) + ": size="+fmi.width.to_string+"x"+fmi.height.to_string+"%N"
						logfile.put_string (msg)
						print (msg)
						do_stuff_with_fmi (fmi, outdir, dir.item (i))
					end
				end
				i := i + 1
			end
		end

feature -- Constants

	datadir: STRING is "data"

	srcdir: STRING is "src"

	logfilename: STRING is "template.log"

end -- class PACKAGE_MAKER
