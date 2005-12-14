#include <stdio.h>
#include <stdlib.h>
#include <SDL/SDL.h>
#include <assert.h>
#include "img_loader.h"


/* Los *fing vienen a ser los 'int i, j, k;' contadores genericos.  Por amor a
 * la claridad, tengo uno por cada cosa que recorro, y los nombro
 * correspondientemente
 */

/* Used for loading all kinds of 8bit images and animations */
static int loadPalette (SDL_RWops *src, Uint32 *palette)
{
  Uint32 palfing;            /* Finger into palette */
  Uint8 palcount[2];         /* transparent flag + palette count */

  Uint32 usedcolor[257];
  Uint16 i ;

  /* Load Palette Count */
  if (SDL_RWread (src, palcount, 1, 2) != 2){
    SDL_SetError("Error reading from file\n");
    return 1;
  }

  for (i = 0; i <= 256; i++) usedcolor[i] = 0 ;
  /* Load Palette */
  for (palfing = 0; palfing <= palcount[1]; palfing++){
    Uint16 color ;
    SDL_RWread(src, &color, 1, 2);
    palette[palfing] = color ;
    if (color<257)
      usedcolor[color] = 1 ;
  }
  if (palcount[0]) { /* Transparent image */
    /* Find a free color. They will be one by pigeon-hole theorem */
    for (i=0; usedcolor[i]; i++) ;
    /* Set the color key to the free color */
    palette[0xff] = i ;
  }
  return 0;
}

/* Used for loading 8bit plain images and animations */
static void loadPixels_plain8 (SDL_RWops *src, SDL_Surface *s, Uint32 *palette, INTEGER w, INTEGER h)
{
  Uint8 *filebuffer;          /* Input file buffer */
  Uint32 filefing,            /* Finger into file */
    scanline = 0,             /* Offset within s->pixels to previous beginning of scanline */
    offset = 0;               /* Absolute offset within s->pixels */
  
  /* Set Surface flags */
  SDL_SetColorKey (s, SDL_SRCCOLORKEY|SDL_RLEACCEL, palette[0xFF]) ;
  
  filebuffer = (Uint8*) malloc (sizeof(Uint8) * w * h);
  
  /* Load file into buffer */
  SDL_RWread(src, filebuffer, 1, w * h);
  
  /* Move buffer into s->pixels, looking up in palette */
  for (filefing = 0; filefing < w * h;){
    ((Uint16*)(s->pixels))[offset] = palette[filebuffer[filefing]] ;
    filefing++;
    if (filefing % w)
      offset ++;
    else {
      /*FIXME: this is broen if pitch is odd. This happens several times in
	this module*/
      offset = scanline + (s -> pitch >> 1);
      scanline = offset;
    }
  }
  free (filebuffer);
}

static void loadPixels_rle8 (SDL_RWops *src, SDL_Surface *s, Uint32 *palette, INTEGER w, INTEGER h)
{
  int initial_pos;     /* Initial Position in RWOps */
  Uint8 tplhdr[4],     /* Fixed header for each tuple */
    tpllist[256];      /* Non-repeated pixels buffer */
  Uint32 tcount,       /* Tuple count */
    tlfing,            /* Tuple List Finger */
    filefing = 0,      /* Byte offset indicator within file */
    imgfing = 0,       /* Pixel finger within image */
    offset=0,          /* Absolut Offset within s->pixels */
    scanline=0,        /* Offset within s->pixels to last beginning of scanline */
    pixel;             /* Current pixel value */
  Uint8 tupfing;       /* Tuple cursor */
  int res = 0 ;


  /* Set Surface flags */
  res = SDL_SetColorKey (s, SDL_SRCCOLORKEY|SDL_RLEACCEL, palette[0xFF]) ;
  assert (res==0) ;

  SDL_RWread(src, &tcount, 4, 1);
    
  initial_pos = SDL_RWtell(src);
  /* filefing points to beginning of tuple */
  for (tlfing = 0; tlfing < tcount; tlfing++){
    SDL_RWread(src, tplhdr, 1, 3);
    /* pixel holds repeated pixel */
    pixel = palette[tplhdr[2]];
    /* Repeat the repeated pixel n times */
    for (tupfing = tplhdr[0]; tupfing; tupfing--){
      ((Uint16*)(s->pixels))[offset] = pixel ;
      imgfing++;
      if (imgfing % w)
	offset ++;
      else{
	offset = scanline + (s -> pitch >> 1);
	scanline = offset;
      }
    }
    /* filefing now points to beginning of non-repeat list */
    SDL_RWread(src, tpllist, 1, tplhdr[1]);
    /* Read in non-repeat list */
    for (tupfing = tplhdr[1], filefing = 0; tupfing; tupfing--) {
      ((Uint16*)(s->pixels))[offset] = palette[tpllist[filefing]] ;
      imgfing++;
      filefing++;
      if (imgfing % w)
	offset ++;
      else {
	offset = scanline + (s -> pitch >> 1);
	scanline = offset;
      }
    }
    /* filefing points to beginning of next tuple */
  }
}

static void loadPixels_plain16 (SDL_RWops *src, SDL_Surface *s, Uint32 *palette, INTEGER w, INTEGER h)
{
  Uint32 filefing = 0,      /* Finger to position inside file*/
    imgfing,                /* Image cursor */
    size,                   /* size = w * h; */
    offset = 0,             /* Absolute Offset within s->pixels */
    scanline = 0;           /* Offset within s->pixels to previous begining of scanline */
  Uint8 *filebuffer;        /* Input file buffer */
  

  size=w*h;
  
  filebuffer = (Uint8*) malloc (sizeof(Uint8) * 3 * size);
    
  SDL_RWread(src, filebuffer, 3, w*h);
  SDL_LockSurface(s);
  
  for (imgfing = 0; imgfing < size;) {
    /* This code is endian dependant */
    
    /* Store value in s->pixels */
    ((Uint8*)(s->pixels))[offset] = filebuffer[filefing];
    ((Uint8*)(s->pixels))[offset+1] = filebuffer[filefing + 1];
    ((Uint8*)(s->pixels))[offset+2] = filebuffer[filefing + 2];
    
    /* Adjust filefing and offset */
    filefing+=3;
    imgfing++;
    if (imgfing % w)
      offset += 3;
    else {
      offset = scanline + s -> pitch;
      scanline = offset;
    }
  }
  SDL_UnlockSurface(s);
  free (filebuffer);
}

static void loadPixels_rle16 (SDL_RWops *src, SDL_Surface *s, Uint32 *palette, INTEGER w, INTEGER h)
{
  int initial_pos;                /* Initial Position in RWOps */
  Uint8 *filebuffer;              /* Input file buffer */
  Uint32 tlfing,                  /* Tuple List cursor */
    filefing = 4,                 /* Finger to position inside Input file */
    imgfing = 0,                  /* Pixel offset in image */
    offset = 0,                   /* Offset within s->pixels */
    scanline = 0,                 /* Offset within s->pixels to previous beginning of scanline */
    tcount,                       /* Tuple count */
    tupfing;                      /* Finger to follow Tuple */
  
  initial_pos = SDL_RWtell(src);
  
  filebuffer = (Uint8*) malloc (sizeof(Uint8) * 3 * w * h);

  SDL_RWread(src, filebuffer, 1, 3*w*h);

  tcount = ((Uint32*)filebuffer)[0];

  /* filefing points to beginning of ps */
  for (tlfing = tcount; tlfing; tlfing--) {
    /* Repeat n times */
    for (tupfing = filebuffer[filefing]; tupfing; tupfing--) {
      ((Uint8*)s->pixels)[offset + 1] = filebuffer[filefing + 2];
      ((Uint8*)s->pixels)[offset + 2] = filebuffer[filefing + 3];
      imgfing++;
      if (imgfing % w)
	offset += 3;
      else {
	offset = scanline + s -> pitch;
	scanline = offset;
      }
    }
    /* filefing now points at beginning of xs */
    filefing += 4;
    for (tupfing = filebuffer[filefing - 3]; tupfing; tupfing--) {
      ((Uint8*)s->pixels)[offset + 1]= filebuffer[filefing];
      ((Uint8*)s->pixels)[offset + 2] = filebuffer[filefing + 1];
      imgfing++;
      if (imgfing % w)
	offset += 3;
      else {
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
  for (tlfing = tcount; tlfing; tlfing--) {
    /* Repeat n times */
    for (tupfing = filebuffer[filefing]; tupfing; tupfing--) {
      ((Uint8*)s->pixels)[offset] = filebuffer[filefing + 2];
      imgfing++;
      if (imgfing % w)
	offset += 3;
      else {
	offset = scanline + s -> pitch;
	scanline = offset;
      }
    }
    /* filefing now points at beginning of xs */
    filefing += 3;
    for (tupfing = filebuffer[filefing - 2]; tupfing; tupfing--) {
      ((Uint8*)s->pixels)[offset] = filebuffer[filefing];
      imgfing++;
      if (imgfing % w)
	offset += 3;
      else {
	offset = scanline + s -> pitch;
	scanline = offset;
      }
      filefing++;
    }
    /* filefing now points to beginning of next ps */
  }
  SDL_RWseek(src, initial_pos + filefing, SEEK_SET);
  free (filebuffer);

}

/* Public Interface for loading FMI images */

INTEGER load_img_plain8 (FILE *f, SDL_Surface *s, INTEGER w, INTEGER h)
{
  SDL_RWops *src;             /* Input File */
  Uint32 palette[256] = {0};  /* Color palette */

  src = SDL_RWFromFP(f, 0);

  if (loadPalette(src, palette))
    return 1;

  loadPixels_plain8 (src, s, palette, w, h);

  return 0;
}


INTEGER load_img_rle8 (FILE *f, SDL_Surface *s, INTEGER w, INTEGER h)
{
  SDL_RWops *src;            /* Input file */
  Uint32 palette[256] = {0}; /* Palette */

  src = SDL_RWFromFP(f, 0);

  if (loadPalette(src, palette))
    return 1;

  loadPixels_rle8 (src, s, palette, w, h);

  return 0;
}


INTEGER load_img_plain16 (FILE *f, SDL_Surface *s, INTEGER w, INTEGER h)
{
  SDL_RWops *src;           /* Input file */

  src = SDL_RWFromFP(f, 0);

  loadPixels_plain16 (src, s, NULL, w, h);
  return 0;
}


INTEGER load_img_rle16 (FILE *f, SDL_Surface *s, INTEGER w, INTEGER h)
{
  SDL_RWops *src;                 /* Input file */

  src = SDL_RWFromFP(f, 0);
  loadPixels_rle16(src, s, NULL, w, h);

  return 0;
}

/* Autodetects type and size for FMI images */
/* File isn't closed on exit */
SDL_Surface *FMI_Load(FILE* fp)
{
  SDL_Surface *surface;
  SDL_RWops *src;
  Uint32 magic;
  Uint16 width, height;

  /* Read type and size */
  src = SDL_RWFromFP (fp, 0);
  if (SDL_RWread (src, &magic, 4, 1) != 1) {
    SDL_SetError("Error Opening file\n");
    return 0;
  }

  /* Read width and height */
  SDL_RWread (src, &width, sizeof (width), 1);
  SDL_RWread (src, &height, sizeof (height), 1);

  if (magic>>24=='8')
      surface = SDL_CreateRGBSurface(SDL_HWSURFACE|SDL_SRCCOLORKEY|SDL_RLEACCEL,
                                   width, height, 16, 0xf800, 0x07e0, 0x001f, 0);
  else
      surface = SDL_CreateRGBSurface(SDL_HWSURFACE|SDL_SRCALPHA,
                                   width, height, 24, 0xf80000, 0x07e000, 0x001f00, 0x0000ff);

  if (!surface)
    return 0;

  switch (magic) {
  case 0x38474d49:
    load_img_plain8 (fp, surface, width, height);
    break;
  case 0x38454c52:
    load_img_rle8 (fp, surface, width, height);
    break;
  case 0x36474d49:
    load_img_plain16 (fp, surface, width, height);
    break;
  case 0x36454c52:
    load_img_rle16 (fp, surface, width, height);
    break;
  default:
    return 0;
  }
  return surface;
}


/* Public interface for loading FMA animations. */
/* File isn't closed on exit */
FMA_t *load_anim (FILE *f)
{
    FMA_t *answer = NULL;
    SDL_RWops *src = NULL;     /* Input file */
    Uint32 palette[256] = {0}; /* Palette */
    Uint32 magic = 0 ;
    Uint16 imgcount[2],        /* Image Count and Loop-start indicator */
         delta_n_size[4],      /* Displacement and size for each image */
         imgfing;              /* Finger into images */
    void (*loadpix)(SDL_RWops *, SDL_Surface*, Uint32*, INTEGER, INTEGER) = NULL;
    int usecolorkey = 0 ;
    int res = 0 ;

    src = SDL_RWFromFP(f, 0);
    assert (src!=NULL);

    answer = (FMA_t *)calloc(1, sizeof(FMA_t));
    assert (answer!=NULL);

    /* Read type and size */
    if (SDL_RWread (src, &magic, sizeof(magic), 1) != 1)
    {
        SDL_SetError("Error Opening file\n");
        fprintf (stderr, "load_anim: File access error, apparently not open.\n");
        return NULL;
    }

    /* Read Image Count */
    res = SDL_RWread (src, imgcount, 2, 2);
    if (res != 2)
    {
        fprintf (stderr, "load_anim: Error reading imagge count.\n");
        return NULL;
    }

    answer->count = imgcount[0];
    answer->loopstart = imgcount[1];
    answer->x = (int *) calloc(imgcount[0], sizeof(int));
    answer->y = (int *) calloc(imgcount[0], sizeof(int));
    answer->items = (SDL_Surface **) calloc(imgcount[0], sizeof(SDL_Surface*));
    assert (answer->x!=NULL && answer->y!=NULL && answer->items!=NULL) ;

    switch(magic)
    {
    case 0x38494e41:
/*        printf("Plain 8 bit images\n"); */
        loadpix = loadPixels_plain8;
        usecolorkey = 1 ;
        if (loadPalette(src, palette)) {
            fprintf (stderr, "load_anim: Error loading palette.\n");
            return NULL;
        }
        break;
    case 0x38414c52:
        loadpix = loadPixels_rle8;
        usecolorkey = 1 ;
        if (loadPalette(src, palette)) {
            fprintf (stderr, "load_anim: Error loading palette.\n");
            return NULL;
        }
        break;
    case 0x36494e41:
        loadpix = loadPixels_plain16;
        break;
    case 0x36414c52:
        loadpix = loadPixels_rle16;
        break;
    default:
        fprintf (stderr, "load_anim: Bad magic number.\n");
        return NULL;
    }

    for(imgfing = 0; imgfing < imgcount[0]; imgfing++)
    {
        res = SDL_RWread (src, delta_n_size, 2, 4);
        if (res<4) {
            fprintf (stderr, "load_anim: couldn't read frame dimensions.\n");
            return NULL;
        }

        /*printf("Loading %dx%d image displaced %dx%d...\n", delta_n_size[2], delta_n_size[3], delta_n_size[0], delta_n_size[1]);*/
        if (usecolorkey)
            answer->items[imgfing] = SDL_CreateRGBSurface(SDL_HWSURFACE|SDL_SRCCOLORKEY|SDL_RLEACCEL,
                                         delta_n_size[2], delta_n_size[3], 16, 0xf800, 0x07e0, 0x001f, 0);
        else
            answer->items[imgfing] = SDL_CreateRGBSurface(SDL_HWSURFACE|SDL_SRCALPHA,
                                         delta_n_size[2], delta_n_size[3], 24, 0xf80000, 0x07e000, 0x001f00, 0x0000ff);
        if (answer->items[imgfing]==NULL) {
            fprintf (stderr, "load_anim: CreateRGBSurface failed\n");
            fprintf (stderr, "  %dx%d %s\n", delta_n_size[2], delta_n_size[3], usecolorkey?"colorkey":"nocolorkey");
            return NULL;
        }
        answer->x[imgfing] = delta_n_size[0];
        answer->y[imgfing] = delta_n_size[1];
        loadpix (src, answer->items[imgfing], palette, delta_n_size[2], delta_n_size[3]);
    }

    if (answer==NULL) {
        fprintf (stderr, "load_anim: returning NULL.\n"); /* Should never happen */
    }
    return answer;
}


/* Frees x, y & items (_not_ *items) */
void free_FMA (FMA_t *anim)
{
  free (anim->x);
  free (anim->y);
  free (anim->items);
  free (anim);
  return;
}

