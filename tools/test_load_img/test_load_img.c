#include <stdio.h>
#include <unistd.h>
#include <assert.h>
#include "../../client/src/C/img_loader.h"

#define SCR_WIDTH 640
#define SCR_HEIGHT 480


int main(int argc, char* argv[])
{
    FILE *fp;
    SDL_Surface *screen, *surface;

    if (argc != 2)
    {
        printf("Usage: test_img_loader <filename>\n");
        return 0;
    }

    fp = fopen (argv[1], "r");
    SDL_Init(SDL_INIT_VIDEO);
    screen = SDL_SetVideoMode (SCR_WIDTH, SCR_HEIGHT, 0, SDL_HWSURFACE);
    assert (screen!=NULL) ;

    surface = FMI_Load(fp);
    assert (surface!=NULL) ;

    /* Fill scren backgroiund with some solid color */
    SDL_FillRect (screen, NULL, SDL_MapRGB (screen->format, 0,0,128) ) ;

    SDL_BlitSurface(surface, 0, screen, 0);
    SDL_Flip (screen);
    getchar();
    return 0;
}
