#!/usr/bin/env tcc
#include <stdio.h>

int main()
{
    int i, j;


    FILE *fp;
    fp = fopen ("animr8.fma", "w");

/* Magic Number 38414c52 */
    fputc (0x52, fp);
    fputc (0x4c, fp);
    fputc (0x41, fp);
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



/* First Image */
/* DeltaX = 0, DeltaY = 0 (Intel Endian)*/
    fputc (0, fp);
    fputc (0, fp);
    fputc (0, fp);
    fputc (0, fp);
/* Width = 400, Height = 400 (Intel Endian)*/
    fputc (144, fp);
    fputc (1, fp);
    fputc (144, fp);
    fputc (1, fp);

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

/* Second Image */
/* DeltaX = 30, DeltaY = 50 (Intel Endian)*/
    fputc (0x1e, fp);
    fputc (0x00, fp);
    fputc (0x32, fp);
    fputc (0x00, fp);
/* Width = 40, Height = 40 (Intel Endian)*/
    fputc (0x28, fp);
    fputc (0x00, fp);
    fputc (0x28, fp);
    fputc (0x00, fp);

/*Number of Tuples */
    fputc (0x50, fp);
    fputc (0x00, fp);
    fputc (0x00, fp);
    fputc (0x00, fp);

    for (i = 0; i < 20; i++)
    {
        fputc (20, fp);
        fputc (0, fp);
        fputc (0, fp);
        fputc (20, fp);
        fputc (0, fp);
        fputc (1, fp);
    }
    for (i = 0; i < 20; i++)
    {
        fputc (20, fp);
        fputc (0, fp);
        fputc (2, fp);
        fputc (20, fp);
        fputc (0, fp);
        fputc (3, fp);
    }


/* Third Image */
/* DeltaX = 60, DeltaY = 100 (Intel Endian)*/
    fputc (0x3c, fp);
    fputc (0x00, fp);
    fputc (0x64, fp);
    fputc (0x00, fp);
/* Width = 40, Height = 40 (Intel Endian)*/
    fputc (0x28, fp);
    fputc (0x00, fp);
    fputc (0x28, fp);
    fputc (0x00, fp);

/*Number of Tuples */
    fputc (0x50, fp);
    fputc (0x00, fp);
    fputc (0x00, fp);
    fputc (0x00, fp);

    for (i = 0; i < 20; i++)
    {
        fputc (20, fp);
        fputc (0, fp);
        fputc (1, fp);
        fputc (20, fp);
        fputc (0, fp);
        fputc (2, fp);
    }
    for (i = 0; i < 20; i++)
    {
        fputc (20, fp);
        fputc (0, fp);
        fputc (3, fp);
        fputc (20, fp);
        fputc (0, fp);
        fputc (0, fp);
    }


/* Fourth Image */
/* DeltaX = 90, DeltaY = 150 (Intel Endian)*/
    fputc (0x5a, fp);
    fputc (0x00, fp);
    fputc (0x96, fp);
    fputc (0x00, fp);
/* Width = 40, Height = 40 (Intel Endian)*/
    fputc (0x28, fp);
    fputc (0x00, fp);
    fputc (0x28, fp);
    fputc (0x00, fp);

/*Number of Tuples */
    fputc (0x50, fp);
    fputc (0x00, fp);
    fputc (0x00, fp);
    fputc (0x00, fp);

    for (i = 0; i < 20; i++)
    {
        fputc (20, fp);
        fputc (0, fp);
        fputc (2, fp);
        fputc (20, fp);
        fputc (0, fp);
        fputc (3, fp);
    }
    for (i = 0; i < 20; i++)
    {
        fputc (20, fp);
        fputc (0, fp);
        fputc (0, fp);
        fputc (20, fp);
        fputc (0, fp);
        fputc (1, fp);
    }

/* Fifth Image */
/* DeltaX = 120, DeltaY = 200 (Intel Endian)*/
    fputc (0x78, fp);
    fputc (0x00, fp);
    fputc (0xc8, fp);
    fputc (0x00, fp);
/* Width = 40, Height = 40 (Intel Endian)*/
    fputc (0x28, fp);
    fputc (0x00, fp);
    fputc (0x28, fp);
    fputc (0x00, fp);

/*Number of Tuples */
    fputc (0x50, fp);
    fputc (0x00, fp);
    fputc (0x00, fp);
    fputc (0x00, fp);

    for (i = 0; i < 20; i++)
    {
        fputc (20, fp);
        fputc (0, fp);
        fputc (3, fp);
        fputc (20, fp);
        fputc (0, fp);
        fputc (0, fp);
    }
    for (i = 0; i < 20; i++)
    {
        fputc (20, fp);
        fputc (0, fp);
        fputc (1, fp);
        fputc (20, fp);
        fputc (0, fp);
        fputc (2, fp);
    }



    fclose (fp);
}
