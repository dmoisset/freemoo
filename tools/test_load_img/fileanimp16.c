#!/usr/bin/env tcc
#include <stdio.h>

int main()
{
    int i, j;


    FILE *fp;
    fp = fopen ("animp16.fma", "w");

/* Magic Number 36474d49 */
    fputc (0x49, fp);
    fputc (0x4d, fp);
    fputc (0x47, fp);
    fputc (0x36, fp);

/* Image Count = 5 */
    fputc (0x05, fp);
    fputc (0x00, fp);

/* Loop Start = 2 */
    fputc (0x02, fp);
    fputc (0x00, fp);

/* First Image: dx = dy = 0, w = h = 100 */
    fputc(0x00, fp);
    fputc(0x00, fp);
    fputc(0x00, fp);
    fputc(0x00, fp);
    fputc(0x64, fp);
    fputc(0x00, fp);
    fputc(0x64, fp);
    fputc(0x00, fp);


    for (i = 0; i < 50; i++)
    {
        for (j = 0; j < 50; j++)
        {
            fputc (0xf8, fp);
            fputc (0xe5, fp);
            fputc (0xff, fp);
        }
        for (j = 0; j < 50; j++)
        {
            fputc (0x04, fp);
            fputc (0xe0, fp);
            fputc (0xff, fp);
        }
    }
    for (i = 0; i < 50; i++)
    {
        for (j = 0; j < 50; j++)
        {
            fputc (0xd1, fp);
            fputc (0x3d, fp);
            fputc (0xff, fp);
        }
        for (j = 0; j < 50; j++)
        {
            fputc (0x4d, fp);
            fputc (0x87, fp);
            fputc (0xff, fp);
        }
    }

/* Second Image: dx = dy = 30, w = 120, h = 50 */
    fputc(0x1e, fp);
    fputc(0x00, fp);
    fputc(0x1e, fp);
    fputc(0x00, fp);
    fputc(0x78, fp);
    fputc(0x00, fp);
    fputc(0x32, fp);
    fputc(0x00, fp);


    for (i = 0; i < 25; i++)
    {
        for (j = 0; j < 60; j++)
        {
            fputc (0x48, fp);
            fputc (0x25, fp);
            fputc (0xff, fp);
        }
        for (j = 0; j < 60; j++)
        {
            fputc (0x76, fp);
            fputc (0xff, fp);
            fputc (0xff, fp);
        }
    }
    for (i = 0; i < 25; i++)
    {
        for (j = 0; j < 60; j++)
        {
            fputc (0x1f, fp);
            fputc (0x31, fp);
            fputc (0xff, fp);
        }
        for (j = 0; j < 60; j++)
        {
            fputc (0xff, fp);
            fputc (0xff, fp);
            fputc (0xff, fp);
        }
    }


/* Third Image: dx=50,  = dy = 30, w = 80, h = 100 */
    fputc(0x32, fp);
    fputc(0x00, fp);
    fputc(0x1e, fp);
    fputc(0x00, fp);
    fputc(0x50, fp);
    fputc(0x00, fp);
    fputc(0x64, fp);
    fputc(0x00, fp);


    for (i = 0; i < 50; i++)
    {
        for (j = 0; j < 40; j++)
        {
            fputc (0xf3, fp);
            fputc (0x1f, fp);
            fputc (0xff, fp);
        }
        for (j = 0; j < 40; j++)
        {
            fputc (0xff, fp);
            fputc (0x3f, fp);
            fputc (0xff, fp);
        }
    }
    for (i = 0; i < 50; i++)
    {
        for (j = 0; j < 40; j++)
        {
            fputc (0x4f, fp);
            fputc (0xf2, fp);
            fputc (0xff, fp);
        }
        for (j = 0; j < 40; j++)
        {
            fputc (0xf3, fp);
            fputc (0xfd, fp);
            fputc (0xff, fp);
        }
    }

/* Fourth Image: dx=150,  = dy = 130, w = h = 40 */
    fputc(0x96, fp);
    fputc(0x00, fp);
    fputc(0x82, fp);
    fputc(0x00, fp);
    fputc(0x28, fp);
    fputc(0x00, fp);
    fputc(0x28, fp);
    fputc(0x00, fp);


    for (i = 0; i < 20; i++)
    {
        for (j = 0; j < 20; j++)
        {
            fputc (0xfd, fp);
            fputc (0xfd, fp);
            fputc (0xff, fp);
        }
        for (j = 0; j < 20; j++)
        {
            fputc (0x1f, fp);
            fputc (0x32, fp);
            fputc (0xff, fp);
        }
    }
    for (i = 0; i < 20; i++)
    {
        for (j = 0; j < 20; j++)
        {
            fputc (0x62, fp);
            fputc (0x64, fp);
            fputc (0xff, fp);
        }
        for (j = 0; j < 20; j++)
        {
            fputc (0x34, fp);
            fputc (0x27, fp);
            fputc (0xff, fp);
        }
    }

/* Fifth Image: dx=0,  = dy = 100, w = h = 40 */
    fputc(0x00, fp);
    fputc(0x00, fp);
    fputc(0x64, fp);
    fputc(0x00, fp);
    fputc(0x28, fp);
    fputc(0x00, fp);
    fputc(0x28, fp);
    fputc(0x00, fp);


    for (i = 0; i < 20; i++)
    {
        for (j = 0; j < 20; j++)
        {
            fputc (0x88, fp);
            fputc (0x05, fp);
            fputc (0xff, fp);
        }
        for (j = 0; j < 20; j++)
        {
            fputc (0xf8, fp);
            fputc (0x43, fp);
            fputc (0xff, fp);
        }
    }
    for (i = 0; i < 20; i++)
    {
        for (j = 0; j < 20; j++)
        {
            fputc (0xff, fp);
            fputc (0x25, fp);
            fputc (0xff, fp);
        }
        for (j = 0; j < 20; j++)
        {
            fputc (0xf4, fp);
            fputc (0x32, fp);
            fputc (0xff, fp);
        }
    }



    fclose (fp);
}



