#include <stdio.h>
#include <unistd.h>
#include "../../client/src/C/img_loader.h"

#define SCR_WIDTH 640
#define SCR_HEIGHT 480


int main(int argc, char* argv[])
{
    FILE *fp;
    SDL_Surface *screen;
    FMA_t *anim;
    SDL_Rect src, dst;
    int j, i;

    src.x = 0;
    src.y = 0;

    if (argc != 2)
    {
        printf("Usage: test_load_anim <filename>\n");
        return 0;
    }

    fp = fopen (argv[1], "r");
    SDL_Init(SDL_INIT_VIDEO);
    screen = SDL_SetVideoMode (SCR_WIDTH, SCR_HEIGHT, 0, SDL_HWSURFACE);


    anim = load_anim(fp);


    for(i=0; i<anim->count;i++)
    {
        SDL_FillRect (screen, NULL, SDL_MapRGB (screen->format, 0,0,128) );
        src.w = anim->items[i]->w;
        src.h = anim->items[i]->h;
        dst.x = anim->x[i];
        dst.y = anim->y[i];
        SDL_BlitSurface(anim->items[i], &src, screen, &dst);
        SDL_Flip (screen);
        usleep(200000);
    }

    j = 10;
    while(j--)
    {
        for(i=anim->loopstart; i<anim->count;i++)
        {
            SDL_FillRect (screen, NULL, SDL_MapRGB (screen->format, 0,0,128) );
            src.x = 0;
            src.y = 0;
            src.w = anim->items[i]->w;
            src.h = anim->items[i]->h;
            dst.x = anim->x[i];
            dst.y = anim->y[i];
            dst.w = screen->w;
            dst.h = screen->h;
            SDL_BlitSurface(anim->items[i], &src, screen, &dst);
            SDL_Flip (screen);
            usleep(200000);
        }
    }

    return 0;
}
