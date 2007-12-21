
This directory contains the code to build two tools:
 - template_maker, a tool to create a set of blank PNGs you can edit to create
   your own dataset for FreeMoo and a script to reconvert them in to FreeMoo data.
 - model_maker, a tool to create a set of PNGs from the current image
   data, that you can then use as models for your own images.

Compilation
~~~~~~~~~~~

just use:
 make
to compile both tools, or
 make template
to compile only template_maker, or
 make model
to compile only model_maker.

 These tools use imagemagick's convert, so you'll need that installed to use them!

Using template_maker
~~~~~~~~~~~~~~~~~~~~

  Run this tool supplying the path to your current freeMoo data tree:
        ./template_maker /home/me/path/to/moodata/moodata
  It will create a folder named data/ containing two things:
   * A folder named src/
   * A script named template.pack.sh
  Within src you'll find a directory structure identycal to that of the current
data file, but containing blank pngs that you can use to create your own data set
for FreeMoo.
  For each FMI in the original data set you'll have one PNG, and for each FMA in 
the data set you'll have N PNGs, one for each frame of the FMA.
  Edit these PNGs to your heart's content.

Once you've finished editing the PNGs, if you run the template.pack.sh script it
will create a folder named packed/ containing FMIs and FMAs created by packing
the PNGs in src/.

  That is, you should end up with something like:
template_maker
            \-- template_maker
             \-- data
                  \-- src
                   \    \-- ... (lots of pngs...)
                    \--packed
                     \   \-- ... (lots of FMIs and FMAs...)
                      \-- template.pack.sh

template.pack.sh requires you to have png2fmi and fmi2fma in your execution path.
You can find these two tools in the freemoo-freedata package.

Using model_maker
~~~~~~~~~~~~~~~~~
This tool can help you get an idea of what should go in each PNG.
Provide a path to your current freeMoo data tree:
       ./model_maker /home/me/path/to/moodata/moodata
  It will create a folder named data/ with a directory structure identycal to
that of the current data file, but containing PNGs that show you what the
current data set looks like.
