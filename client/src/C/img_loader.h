#ifndef IMG_LOADER_H
#define IMG_LOADER_H

#include <SDL/SDL.h>

#define INTEGER int


/* Load image in given format from `f', into a surface `s'.
 * Assumes image is `w'×`h' pixels, `f' is open, and `s' is allocated
 * and has format (565RGB + 8 alpha).
 *
 * Assumes headers (magic, width, height) has been already read.
 *
 * Return 0 on success, non-zero on failure.
 */

INTEGER load_img_plain8 (FILE *f, SDL_Surface *s, INTEGER w, INTEGER h) ;
INTEGER load_img_plain16 (FILE *f, SDL_Surface *s, INTEGER w, INTEGER h) ;
INTEGER load_img_rle8 (FILE *f, SDL_Surface *s, INTEGER w, INTEGER h) ;
INTEGER load_img_rle16 (FILE *f, SDL_Surface *s, INTEGER w, INTEGER h) ;

/*  Load FMI Image.  Detects width, height and type.
 *  Returns NULL upon failure
 */
SDL_Surface *FMI_Load(const char* filename);

#endif
