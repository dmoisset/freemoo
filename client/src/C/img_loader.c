#include <SDL/SDL.h>
#include "misc.h"
#include "img_loader.h"

INTEGER load_img_plain8 (FILE *f, SDL_Surface *s, INTEGER w, INTEGER h)
{
    SDL_RWops *src;
    Uint8 pcount[2];
    int counter;
    Uint32 palette[256] = {0};
    Uint8 pixels [w * h];

    src = SDL_RWFromFP(f, 0);

/* Print info */
    debug ("Recieved %dbpp %dx%d surface\n", (s->format)->BitsPerPixel, s->w, s->h);
    debug ("Red: Mask=%p, Shift=%d, Loss=%d\n", (void*)(s->format)->Rmask, (s->format)->Rshift, (s->format)->Rloss);
    debug ("Green: Mask=%p, Shift=%d, Loss=%d\n", (void*)(s->format)->Gmask, (s->format)->Gshift, (s->format)->Gloss);
    debug ("Blue: Mask=%p, Shift=%d, Loss=%d\n", (void*)(s->format)->Bmask, (s->format)->Bshift, (s->format)->Bloss);
    debug ("Alpha: Mask=%p, Shift=%d, Loss=%d\n", (void*)(s->format)->Amask, (s->format)->Ashift, (s->format)->Aloss);

/* Load Palette Count */
    if (SDL_RWread (src, pcount, 1, 2) != 2)
    {
        SDL_SetError("Error reading from file\n");
        return 1;
    }


/* Load Palette */
    for (counter = 0; counter < pcount[1]; counter++)
    {
        SDL_RWread(src, &palette[counter], 1, 2);
        palette[counter] = (palette[counter] << 8) + 255;
        debug ("Read Color: %p\n", (void*)palette[counter]);
    }


    SDL_RWread(src, &pixels, 1, w * h);

    for (counter = 0; counter < w * h; counter++)
        ((Uint32*)s->pixels)[counter] = palette[pixels[counter]];

    return 0;
}



INTEGER load_img_rle8 (FILE *f, SDL_Surface *s, INTEGER w, INTEGER h)
{
    SDL_RWops *src;
    Uint8 pcount[2];
    Uint32 counter, pindex = 0, rindex = 0;
    Uint32 palette[256] = {0}, tuples, pixel;
    Uint8 pixels [w * h];
    Uint8 repeats;

    src = SDL_RWFromFP(f, 0);

/* Print info */
    debug ("Recieved %dbpp %dx%d surface\n", (s->format)->BitsPerPixel, s->w, s->h);
    debug ("Red: Mask=%p, Shift=%d, Loss=%d\n", (void*)(s->format)->Rmask, (s->format)->Rshift, (s->format)->Rloss);
    debug ("Green: Mask=%p, Shift=%d, Loss=%d\n", (void*)(s->format)->Gmask, (s->format)->Gshift, (s->format)->Gloss);
    debug ("Blue: Mask=%p, Shift=%d, Loss=%d\n", (void*)(s->format)->Bmask, (s->format)->Bshift, (s->format)->Bloss);
    debug ("Alpha: Mask=%p, Shift=%d, Loss=%d\n", (void*)(s->format)->Amask, (s->format)->Ashift, (s->format)->Aloss);

/* Load Palette Count */
    if (SDL_RWread (src, pcount, 1, 2) != 2)
    {
        SDL_SetError("Error reading from file\n");
        return 1;
    }


/* Load Palette */
    for (counter = 0; counter < pcount[1]; counter++)
    {
        SDL_RWread(src, &palette[counter], 1, 2);
        palette[counter] = (palette[counter] << 8) + 255;
        debug ("Read Color: %p\n", (void*)palette[counter]);
    }


    SDL_RWread(src, &tuples, 4, 1);

    SDL_RWread(src, &pixels, 1, w * h);

/* pindex points to beginning of ps */
    for (counter = 0; counter < tuples; counter++)
    {
/* pixel holds repeated pixel */
        pixel = palette[pixels[pindex + 2]];
/* Repeat n times */
        for (repeats = pixels[pindex]; repeats; repeats--)
        {
            ((Uint32*)s->pixels)[rindex] = pixel;
            rindex++;
        }
/* pindex now points to beginning of xs */
        pindex += 3;
        for (repeats = pixels[pindex - 2]; repeats; repeats--)
        {
            ((Uint32*)s->pixels)[rindex] = palette[pixels[pindex]];
            rindex++;
            pindex++;
        }
/* pindex points to beginning of next ps */
    }

    return 0;
}


INTEGER load_img_plain16 (FILE *f, SDL_Surface *s, INTEGER w, INTEGER h)
{
    SDL_RWops *src;
    int counter, index;
    Uint8 pixels[w * h * 3];

    src = SDL_RWFromFP(f, 0);

/* Print info */
    debug ("Recieved %dbpp %dx%d surface\n", (s->format)->BitsPerPixel, s->w, s->h);
    debug ("Red: Mask=%p, Shift=%d, Loss=%d\n", (void*)(s->format)->Rmask, (s->format)->Rshift, (s->format)->Rloss);
    debug ("Green: Mask=%p, Shift=%d, Loss=%d\n", (void*)(s->format)->Gmask, (s->format)->Gshift, (s->format)->Gloss);
    debug ("Blue: Mask=%p, Shift=%d, Loss=%d\n", (void*)(s->format)->Bmask, (s->format)->Bshift, (s->format)->Bloss);
    debug ("Alpha: Mask=%p, Shift=%d, Loss=%d\n", (void*)(s->format)->Amask, (s->format)->Ashift, (s->format)->Aloss);


    SDL_RWread(src, &pixels, 1, 3*w*h);
    for (index = 0, counter = 0; index < h * w; index++, counter += 3)
        ((Uint32*)s->pixels)[index] = pixels[counter] + (pixels[counter + 1] << 8) + (pixels[counter + 2] << 16);

    return 0;
}




INTEGER load_img_rle16 (FILE *f, SDL_Surface *s, INTEGER w, INTEGER h)
{
    SDL_RWops *src;
    int counter;
    Uint8 pixels[w * h * 3];
    Uint32 pindex = 4, rindex = 0, pixel;
    Uint32 tuples, repeats;

    src = SDL_RWFromFP(f, 0);

/* Print info */
    debug ("Recieved %dbpp %dx%d surface\n", (s->format)->BitsPerPixel, s->w, s->h);
    debug ("Red: Mask=%p, Shift=%d, Loss=%d\n", (void*)(s->format)->Rmask, (s->format)->Rshift, (s->format)->Rloss);
    debug ("Green: Mask=%p, Shift=%d, Loss=%d\n", (void*)(s->format)->Gmask, (s->format)->Gshift, (s->format)->Gloss);
    debug ("Blue: Mask=%p, Shift=%d, Loss=%d\n", (void*)(s->format)->Bmask, (s->format)->Bshift, (s->format)->Bloss);
    debug ("Alpha: Mask=%p, Shift=%d, Loss=%d\n", (void*)(s->format)->Amask, (s->format)->Ashift, (s->format)->Aloss);


    SDL_RWread(src, &pixels, 1, 3*w*h);
    tuples = pixels[0] + (pixels[1] << 8) + (pixels[2] << 16) + (pixels[3] << 24);

/* pindex points to beginning of ps */
    for (counter = tuples; counter; counter--)
    {
/* pixel holds repeated pixel */
        pixel = (pixels[pindex + 2] << 8) + (pixels[pindex + 3] << 16);
        debug("Repeat %d times pixel %p, then %d non-repeats",pixels[pindex],(void*)pixel, pixels[pindex+1]);
/* Repeat n times */
        for (repeats = pixels[pindex]; repeats; repeats--)
        {
            ((Uint32*)s->pixels)[rindex] = pixel;
            rindex++;
        }
/* pindex now points at beginning of xs */
        pindex += 4;
        for (repeats = pixels[pindex - 3]; repeats; repeats--)
        {
            ((Uint32*)s->pixels)[rindex] = (pixels[pindex] << 8) + (pixels[pindex + 1] << 16);
            rindex++;
            pindex+=2;
        }
/* pindex now points to beginning of next ps */
    }

    tuples = pixels[pindex] + (pixels[pindex + 1] << 8) + (pixels[pindex + 2] << 16) + (pixels[pindex + 3] << 24);
    pindex += 4;
    rindex = 0;
    debug("------ Alpha");

/* pindex points to beginning of alpha ps */
    for (counter = tuples; counter; counter--)
    {
/* pixel holds repeated pixel */
        pixel = pixels[pindex + 2];
        debug("Repeat %d times pixel %p, then %d non-repeats",pixels[pindex],(void*)pixel, pixels[pindex+1]);
/* Repeat n times */
        for (repeats = pixels[pindex]; repeats; repeats--)
        {
            ((Uint32*)s->pixels)[rindex] += pixel;
            rindex++;
        }
/* pindex now points at beginning of xs */
        pindex += 3;
        for (repeats = pixels[pindex - 2]; repeats; repeats--)
        {
            ((Uint32*)s->pixels)[rindex] += pixels[pindex];
            rindex++;
            pindex++;
        }
/* pindex now points to beginning of next ps */
    }

    return 0;
}