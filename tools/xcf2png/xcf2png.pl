#!/usr/bin/perl -w

#
# This GimpPerl scripts loads an .xcf file (Gimp format), merges its layers,
# And saves it as .png with low compression
#

use Gimp qw(:auto __ N_);
use Gimp::Fu;

sub xcf2png {
    my ($filein, $fileout) = @_;
    $img = gimp_xcf_load (1, $filein, $filein);
    my @l = $img->get_layers () ;
    if ($#l==0) {
        # merge needs two layers, stupid gimp.
        $newlayer = gimp_layer_new ($img, $img->width, $img->height, $img->base_type, "stupid_gimp", 0, 0);
        $img->add_layer ($newlayer, 0)
    }
    $img->merge_visible_layers (CLIP_TO_IMAGE);
    $layer = $img->get_active_layer();
    file_png_save (1, $layer, $fileout, $fileout, 0, 1, 1, 0, 0, 1, 1);
}


register
  "xcf2png",
  "desc",
  "help",
  "author", "(c)", "date",
  N_"<Toolbox>/Xtns/Render/xcf2png...",
  undef,
  [
   [PF_STRING, "filein", "", ""],
   [PF_STRING, "fileout", "", ""]
  ],
  \&xcf2png;

exit main;
