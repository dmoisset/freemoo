#!/usr/bin/env tcc
#include <stdio.h>

int main()
{
    int i, j;


    FILE *fp;
    fp = fopen ("r8.bmp", "w");

/* Magic Number 38454c52 */
    fputc (0x38, fp);
    fputc (0x45, fp);
    fputc (0x4c, fp);
    fputc (0x52, fp);

/* Width = 400, Height = 400 (Intel Endian)*/
    fputc (144, fp);
    fputc (1, fp);
    fputc (144, fp);
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

/*Number of Tuples */
    fputc (32, fp);
    fputc (3, fp);
    fputc (0, fp);
    fputc (0, fp);

    for (i = 0; i < 200; i++)
    {
        fputc (200, fp);
        fputc (0, fp);
        fputc (0, fp);
        fputc (200, fp);
        fputc (0, fp);
        fputc (1, fp);
    }
    for (i = 0; i < 200; i++)
    {
        fputc (200, fp);
        fputc (0, fp);
        fputc (2, fp);
        fputc (200, fp);
        fputc (0, fp);
        fputc (3, fp);
    }
    fclose (fp);
}
