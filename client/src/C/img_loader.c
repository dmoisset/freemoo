#include <stdio.h>
#include <SDL/SDL.h>
#include "img_loader.h"

/* Los *fing vienen a ser los 'int i, j, k;' contadores genericos.  Por amor a la claridad,
 * tengo uno por cada cosa que recorro, y los nombre correspondientemente
 */


INTEGER load_img_plain8 (FILE *f, SDL_Surface *s, INTEGER w, INTEGER h)
{
    SDL_RWops *src;             /* Input File */
    Uint32 palette[256] = {0};  /* Color palette */
    Uint8 palcount[2];          /* dummy byte + palette count */
    Uint8 filebuffer [w * h];   /* Input file buffer */
    Uint32 palfing,             /* Finger into palette */
           filefing,            /* Finger into file */
           scanline = 0,        /* Offset within s->pixels to previous beginning of scanline */
           offset = 0;          /* Absolute offset within s->pixels */

    src = SDL_RWFromFP(f, 0);

/* Load Palette Count */
    if (SDL_RWread (src, palcount, 1, 2) != 2)
    {
        SDL_SetError("Error reading from file\n");
        return 1;
    }

/* Load Palette */
    for (palfing = 0; palfing < palcount[1]; palfing++)
    {
        SDL_RWread(src, &palette[palfing], 1, 2);
        palette[palfing] = (palette[palfing] << 8) + 255;
    }

/* Load file into buffer */
    SDL_RWread(src, &filebuffer, 1, w * h);

/* Move buffer into s->pixels, looking up in palette */
    for (filefing = 0; filefing < w * h;)
    {
        ((Uint8*)(s->pixels))[offset] = palette[filebuffer[filefing]] & 0xFF;
        ((Uint8*)(s->pixels))[offset+1] = (palette[filebuffer[filefing]] >> 8) & 0xFF;
        ((Uint8*)(s->pixels))[offset+2] = (palette[filebuffer[filefing]] >> 16) & 0xFF;
        filefing++;
        if (filefing % w)
            offset += 3;
        else
        {
            offset = scanline + s -> pitch;
            scanline = offset;
        }
    }

    return 0;
}







INTEGER load_img_rle8 (FILE *f, SDL_Surface *s, INTEGER w, INTEGER h)
{
    SDL_RWops *src;            /* Input file */
    Uint32 palette[256] = {0}; /* Palette */
    Uint8 filebuffer [w * h];  /* Input file buffer */
    Uint8 palcount[2];         /* dummy byte + palette count */
    Uint32 palfing,            /* Finger into Palette */
           tcount,             /* Tuple count */
           tlfing,             /* Tuple List Finger */
           filefing = 0,       /* Byte offset indicator within file */
           imgfing = 0,        /* Pixel finger within image */
           offset=0,           /* Absolut Offset within s->pixels */
           scanline=0,         /* Offset within s->pixels to last beginning of scanline */
           pixel;              /* Current pixel value */
    Uint8 tupfing;             /* Tuple cursor */

    src = SDL_RWFromFP(f, 0);

/* Load Palette Count */
    if (SDL_RWread (src, palcount, 1, 2) != 2)
    {
        SDL_SetError("Error reading from file\n");
        return 1;
    }


/* Load Palette */
    for (palfing = 0; palfing < palcount[1]; palfing++)
    {
        SDL_RWread(src, &palette[palfing], 1, 2);
        palette[palfing] = (palette[palfing] << 8) + 255;
    }


    SDL_RWread(src, &tcount, 4, 1);

    SDL_RWread(src, &filebuffer, 1, w * h);

/* filefing points to beginning of tuple */
    for (tlfing = 0; tlfing < tcount; tlfing++)
    {
/* pixel holds repeated pixel */
        pixel = palette[filebuffer[filefing + 2]];
/* Repeat the repeated pixel n times */
        for (tupfing = filebuffer[filefing]; tupfing; tupfing--)
        {
            ((Uint8*)(s->pixels))[offset] = pixel & 0xFF;
            ((Uint8*)(s->pixels))[offset+1] = (pixel >> 8) & 0xFF;
            ((Uint8*)(s->pixels))[offset+2] = (pixel >> 16) & 0xFF;
            imgfing++;
            if (imgfing % w)
                offset += 3;
            else
            {
                offset = scanline + s -> pitch;
                scanline = offset;
            }
        }
/* filefing now points to beginning of non-repeat list */
        filefing += 3;
/* Read in non-repeat list */
        for (tupfing = filebuffer[filefing - 2]; tupfing; tupfing--)
        {
            ((Uint8*)(s->pixels))[offset] = palette[filebuffer[filefing]] & 0xFF;
            ((Uint8*)(s->pixels))[offset+1] = (palette[filebuffer[filefing]] >> 8) & 0xFF;
            ((Uint8*)(s->pixels))[offset+2] = (palette[filebuffer[filefing]] >> 16) & 0xFF;
            imgfing++;
            filefing++;
            if (imgfing % w)
                offset += 3;
            else
            {
                offset = scanline + s -> pitch;
                scanline = offset;
            }
        }
/* filefing points to beginning of next tuple */
    }

    return 0;
}








INTEGER load_img_plain16 (FILE *f, SDL_Surface *s, INTEGER w, INTEGER h)
{
    SDL_RWops *src;           /* Input file */
    Uint32 filefing = 0,      /* Finger to position inside file*/
           imgfing,           /* Image cursor */
           size,              /* size = w * h; */
           offset = 0,        /* Absolute Offset within s->pixels */
           scanline = 0;      /* Offset within s->pixels to previous begining of scanline */
    Uint8 filebuffer[3*w*h];  /* Input file buffer */

    src = SDL_RWFromFP(f, 0);

    size=w*h;

    SDL_RWread(src, &filebuffer, 3, w*h);
    SDL_LockSurface(s);

    for (imgfing = 0; imgfing < size; imgfing++)
    {
/* This code is endian dependant */

/* Store value in s->pixels */
        ((Uint8*)(s->pixels))[offset] = filebuffer[filefing];
        ((Uint8*)(s->pixels))[offset+1] = filebuffer[filefing + 1];
        ((Uint8*)(s->pixels))[offset+2] = filebuffer[filefing + 2];

/* Adjust filefing and offset */
        filefing+=3;
        if (imgfing % w)
            offset += 3;
        else
        {
            offset = scanline + s -> pitch;
            scanline = offset;
        }
    }
    SDL_UnlockSurface(s);
    return 0;
}






INTEGER load_img_rle16 (FILE *f, SDL_Surface *s, INTEGER w, INTEGER h)
{
    SDL_RWops *src;                 /* Input file */
    Uint8 filebuffer[w * h * 3];    /* Input file buffer */
    Uint32 tlfing,                  /* Tuple List cursor */
           filefing = 4,            /* Finger to position inside Input file */
           imgfing = 0,             /* Pixel offset in image */
           offset = 0,              /* Offset within s->pixels */
           scanline = 0,            /* Offset within s->pixels to previous beginning of scanline */
           tcount,                  /* Tuple count */
           tupfing;                 /* Finger to follow Tuple */

    src = SDL_RWFromFP(f, 0);

    SDL_RWread(src, &filebuffer, 1, 3*w*h);

    tcount = ((Uint32*)filebuffer)[0];

/* filefing points to beginning of ps */
    for (tlfing = tcount; tlfing; tlfing--)
    {
/* Repeat n times */
        for (tupfing = filebuffer[filefing]; tupfing; tupfing--)
        {
            ((Uint8*)s->pixels)[offset + 1] = filebuffer[filefing + 2];
            ((Uint8*)s->pixels)[offset + 2] = filebuffer[filefing + 3];
            imgfing++;
            if (imgfing % w)
                offset += 3;
            else
            {
                offset = scanline + s -> pitch;
                scanline = offset;
            }
        }
/* filefing now points at beginning of xs */
        filefing += 4;
        for (tupfing = filebuffer[filefing - 3]; tupfing; tupfing--)
        {
            ((Uint8*)s->pixels)[offset + 1]= filebuffer[filefing];
            ((Uint8*)s->pixels)[offset + 2] = filebuffer[filefing + 1];
            imgfing++;
            if (imgfing % w)
                offset += 3;
            else
            {
                offset = scanline + s -> pitch;
                scanline = offset;
            }
            filefing+=2;
        }
/* filefing now points to beginning of next ps */
    }

    tcount = ((Uint32*)(filebuffer + filefing))[0];
    filefing += 4;
    imgfing = 0;
    offset = 0;
    scanline = 0;

/* filefing points to beginning of alpha ps */
    for (tlfing = tcount; tlfing; tlfing--)
    {
/* Repeat n times */
        for (tupfing = filebuffer[filefing]; tupfing; tupfing--)
        {
            ((Uint8*)s->pixels)[offset] = filebuffer[filefing + 2];
            imgfing++;
            if (imgfing % w)
                offset += 3;
            else
            {
                offset = scanline + s -> pitch;
                scanline = offset;
            }
        }
/* filefing now points at beginning of xs */
        filefing += 3;
        for (tupfing = filebuffer[filefing - 2]; tupfing; tupfing--)
        {
            ((Uint8*)s->pixels)[offset] = filebuffer[filefing];
            imgfing++;
            if (imgfing % w)
                offset += 3;
            else
            {
                offset = scanline + s -> pitch;
                scanline = offset;
            }
            filefing++;
        }
/* filefing now points to beginning of next ps */
    }

    return 0;
}



SDL_Surface *FMI_Load(const char* filename)
{
    FILE *fp;
    SDL_Surface *surface;
    SDL_RWops *src;
    Uint8 magic[4];
    Uint16 width, height;

    if(!(fp = fopen (filename, "r")))
        return 0;


/* Read type and size */
    src = SDL_RWFromFP (fp, 0);
    if (SDL_RWread (src, magic, 1, 4) != 4)
    {
        SDL_SetError("Error Opening file\n");
        return 0;
    }

/* Read width and height */
    SDL_RWread (src, &width, sizeof (width), 1);
    SDL_RWread (src, &height, sizeof (height), 1);

    surface = SDL_CreateRGBSurface(SDL_HWSURFACE, width, height, 24, 0xf80000,
             0x07e000, 0x001f00, 0x0000ff);
    if (!surface)
    {
        return 0;
    }
    if (magic[3] == 0x38)
        if (magic[1] == 0x4d)
            load_img_plain8 (fp, surface, width, height);
        else
            load_img_rle8 (fp, surface, width, height);
    else
        if (magic[1] == 0x4d)
            load_img_plain16 (fp, surface, width, height);
        else
            load_img_rle16 (fp, surface, width, height);

    return surface;

}
