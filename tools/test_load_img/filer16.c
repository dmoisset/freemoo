#!/usr/bin/env tcc
#include <stdio.h>

int main()
{
    int i, j;


    FILE *fp;
    fp = fopen ("r16.bmp", "w");

/* Magic Number 36454c52 */
    fputc (0x36, fp);
    fputc (0x45, fp);
    fputc (0x4c, fp);
    fputc (0x52, fp);

/* Width = 400, Height = 400 (Intel Endian)*/
    fputc (144, fp);
    fputc (1, fp);
    fputc (144, fp);
    fputc (1, fp);

/* Number of Tuples = 800 */
    fputc (32, fp);
    fputc (3, fp);
    fputc (0, fp);
    fputc (0, fp);

    for (i = 0; i < 200; i++)
    {
        fputc(200, fp);
        fputc(0, fp);
        fputc(0x00, fp);
        fputc(0xf8, fp);
        fputc(200, fp);
        fputc(0, fp);
        fputc(0xe0, fp);
        fputc(0x07, fp);
    }
    for (i = 0; i < 200; i++)
    {
        fputc(200, fp);
        fputc(0, fp);
        fputc(0x1f, fp);
        fputc(0x00, fp);
        fputc(200, fp);
        fputc(0, fp);
        fputc(0x43, fp);
        fputc(0x43, fp);
    }

/* Number of Alpha Tuples = 800 */
    fputc (32, fp);
    fputc (3, fp);
    fputc (0, fp);
    fputc (0, fp);

    for (i = 0; i < 800; i++)
    {
        fputc(200, fp);
        fputc(0, fp);
        fputc(0xcf, fp);
    }


    fclose (fp);
}
