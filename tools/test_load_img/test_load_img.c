#include <stdio.h>
#include <unistd.h>
#include "../../client/src/C/img_loader.h"
#include "../../client/src/C/misc.h"

int main(int argc, char* argv[])
{
    FILE *fp;
    SDL_Surface *screen, *surface;
    SDL_RWops *src;
    Uint8 magic[4];
    Uint16 width, height;

    if (argc != 2)
        die("Usage: test_img_loader <filename>");

    fp = fopen (argv[1], "r");
    SDL_Init(SDL_INIT_VIDEO);
    screen = SDL_SetVideoMode (640, 480, 0, SDL_HWSURFACE);


/* Read type and size */
    src = SDL_RWFromFP (fp, 0);
    if (SDL_RWread (src, magic, 1, 4) != 4)
    {
        SDL_SetError("Error Opening file\n");
        return 1;
    }

/* Read width and height */
    SDL_RWread (src, &width, sizeof (width), 1);
    SDL_RWread (src, &height, sizeof (height), 1);

    surface = SDL_CreateRGBSurface(SDL_HWSURFACE, width, height, 32, 0x00f80000,
             0x0007e000, 0x00001f00, 0x000000ff);
    if (!surface)
        die ("Couldn't create surface:  width = %d\theight = %d\n", width, height);
    if (magic[0] == 0x38)
        if (magic[2] == 0x4d)
            load_img_plain8 (fp, surface, width, height);
        else
            load_img_rle8 (fp, surface, width, height);
    else
        if (magic[2] == 0x4d)
            load_img_plain16 (fp, surface, width, height);
        else
            load_img_rle16 (fp, surface, width, height);


    SDL_BlitSurface(surface, 0, screen, 0);
    SDL_Flip (screen);
    sleep (3);
    return 0;
}
