#!/usr/bin/env tcc
#include <stdio.h>

int main()
{
    int i, j;


    FILE *fp;
    fp = fopen ("p16.bmp", "w");

/* Magic Number 38474d49 */
    fputc (0x49, fp);
    fputc (0x4d, fp);
    fputc (0x47, fp);
    fputc (0x36, fp);

/* Width = 638, Height = 480 (Intel Endian)*/
    fputc (126, fp);
    fputc (2, fp);
    fputc (224, fp);
    fputc (1, fp);


    for (i = 0; i < 240; i++)
    {
        for (j = 0; j < 319; j++)
        {
            fputc(0xff, fp);
            fputc(0x00, fp);
            fputc(0xf8, fp);
        }
        for (j = 0; j < 319; j++)
        {
            fputc(0xff, fp);
            fputc(0xe0, fp);
            fputc(0x07, fp);
        }
    }
    for (i = 0; i < 240; i++)
    {
        for (j = 0; j < 319; j++)
        {
            fputc(0xff, fp);
            fputc(0x1f, fp);
            fputc(0x00, fp);
        }
        for (j = 0; j < 319; j++)
        {
            fputc(0xff, fp);
            fputc(0x62, fp);
            fputc(0x43, fp);
        }
    }
    fclose (fp);
}
