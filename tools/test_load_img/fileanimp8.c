#!/usr/bin/env tcc
#include <stdio.h>

int main()
{
    int i, j;


    FILE *fp;
    fp = fopen ("animp8.fma", "w");

/* Magic Number 38474d49 */
    fputc (0x49, fp);
    fputc (0x4d, fp);
    fputc (0x47, fp);
    fputc (0x38, fp);

/* Image Count = 5 */
    fputc (0x05, fp);
    fputc (0x00, fp);

/* Loop Start = 2 */
    fputc (0x02, fp);
    fputc (0x00, fp);

/* Four color palette */
    fputc (0, fp);
    fputc (4, fp);
/* Red */
    fputc (0, fp);
    fputc (0xf8, fp);

/* Green */
    fputc (0xe0, fp);
    fputc (0x07, fp);

/* Blue */
    fputc (0x1f, fp);
    fputc (0, fp);

/* Black */
    fputc (0, fp);
    fputc (0, fp);



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
            fputc (0, fp);
        for (j = 0; j < 50; j++)
            fputc (1, fp);
    }
    for (i = 0; i < 50; i++)
    {
        for (j = 0; j < 50; j++)
            fputc (2, fp);
        for (j = 0; j < 50; j++)
            fputc (3, fp);
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
            fputc (0, fp);
        for (j = 0; j < 60; j++)
            fputc (1, fp);
    }
    for (i = 0; i < 25; i++)
    {
        for (j = 0; j < 60; j++)
            fputc (2, fp);
        for (j = 0; j < 60; j++)
            fputc (3, fp);
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
            fputc (1, fp);
        for (j = 0; j < 40; j++)
            fputc (2, fp);
    }
    for (i = 0; i < 50; i++)
    {
        for (j = 0; j < 40; j++)
            fputc (3, fp);
        for (j = 0; j < 40; j++)
            fputc (0, fp);
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
            fputc (2, fp);
        for (j = 0; j < 20; j++)
            fputc (3, fp);
    }
    for (i = 0; i < 20; i++)
    {
        for (j = 0; j < 20; j++)
            fputc (0, fp);
        for (j = 0; j < 20; j++)
            fputc (1, fp);
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
            fputc (2, fp);
        for (j = 0; j < 20; j++)
            fputc (3, fp);
    }
    for (i = 0; i < 20; i++)
    {
        for (j = 0; j < 20; j++)
            fputc (0, fp);
        for (j = 0; j < 20; j++)
            fputc (1, fp);
    }



    fclose (fp);
}



