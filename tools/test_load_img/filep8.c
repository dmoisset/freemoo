#!/usr/bin/env tcc
#include <stdio.h>

int main()
{
    int i, j;


    FILE *fp;
    fp = fopen ("p8.bmp", "w");

/* Magic Number 38474d49 */
    fputc (0x38, fp);
    fputc (0x47, fp);
    fputc (0x4d, fp);
    fputc (0x49, fp);

/* Width = 640, Height = 480 (Intel Endian)*/
    fputc (128, fp);
    fputc (2, fp);
    fputc (224, fp);
    fputc (1, fp);

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

    for (i = 0; i < 240; i++)
    {
        for (j = 0; j < 320; j++)
            fputc (0, fp);
        for (j = 0; j < 320; j++)
            fputc (1, fp);
    }
    for (i = 0; i < 240; i++)
    {
        for (j = 0; j < 320; j++)
            fputc (2, fp);
        for (j = 0; j < 320; j++)
            fputc (3, fp);
    }
    fclose (fp);
}
