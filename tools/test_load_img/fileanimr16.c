#!/usr/bin/env tcc
#include <stdio.h>

int main()
{
    int i, j;


    FILE *fp;
    fp = fopen ("animr16.fma", "w");

/* Magic Number 36454c52 */
    fputc (0x52, fp);
    fputc (0x4c, fp);
    fputc (0x41, fp);
    fputc (0x36, fp);

/* File Count = 5 */
    fputc (0x05, fp);
    fputc (0x00, fp);

/* Loop Start = 0 */
    fputc (0x00, fp);
    fputc (0x00, fp);

/*First Image */
/* Delta x = 0, Delta y = 0 (Intel Endian)*/
    fputc (0x00, fp);
    fputc (0x00, fp);
    fputc (0x00, fp);
    fputc (0x00, fp);

/* Width = 200, Height = 200 (Intel Endian)*/
    fputc (0xc8, fp);
    fputc (0x00, fp);
    fputc (0xc8, fp);
    fputc (0x00, fp);

/* Number of Tuples = 400 */
    fputc (0x90, fp);
    fputc (0x01, fp);
    fputc (0, fp);
    fputc (0, fp);

    for (i = 0; i < 100; i++)
    {
        fputc(100, fp);
        fputc(0, fp);
        fputc(0x00, fp);
        fputc(0xf8, fp);
        fputc(100, fp);
        fputc(0, fp);
        fputc(0xe0, fp);
        fputc(0x07, fp);
    }
    for (i = 0; i < 100; i++)
    {
        fputc(100, fp);
        fputc(0, fp);
        fputc(0x1f, fp);
        fputc(0x00, fp);
        fputc(100, fp);
        fputc(0, fp);
        fputc(0x43, fp);
        fputc(0x43, fp);
    }

/* Number of Alpha Tuples = 400 */
    fputc (0x90, fp);
    fputc (0x01, fp);
    fputc (0, fp);
    fputc (0, fp);

    for (i = 0; i < 400; i++)
    {
        fputc(100, fp);
        fputc(0, fp);
        fputc(0xcf, fp);
    }


/* Second Image */
/* Delta x = 80, Delta y = 30 (Intel Endian)*/
    fputc (0x50, fp);
    fputc (0x00, fp);
    fputc (0x1e, fp);
    fputc (0x00, fp);

/* Width = 200, Height = 200 (Intel Endian)*/
    fputc (0xc8, fp);
    fputc (0x00, fp);
    fputc (0xc8, fp);
    fputc (0x00, fp);

/* Number of Tuples = 400 */
    fputc (0x90, fp);
    fputc (0x01, fp);
    fputc (0, fp);
    fputc (0, fp);

    for (i = 0; i < 100; i++)
    {
        fputc(100, fp);
        fputc(0, fp);
        fputc(0xe3, fp);
        fputc(0x1e, fp);
        fputc(100, fp);
        fputc(0, fp);
        fputc(0xe2, fp);
        fputc(0xe3, fp);
    }
    for (i = 0; i < 100; i++)
    {
        fputc(100, fp);
        fputc(0, fp);
        fputc(0x1f, fp);
        fputc(0xf1, fp);
        fputc(100, fp);
        fputc(0, fp);
        fputc(0xf1, fp);
        fputc(0x1f, fp);
    }

/* Number of Alpha Tuples = 400 */
    fputc (0x90, fp);
    fputc (0x01, fp);
    fputc (0, fp);
    fputc (0, fp);

    for (i = 0; i < 400; i++)
    {
        fputc(100, fp);
        fputc(0, fp);
        fputc(0xcf, fp);
    }


/* Third Image */
/* Delta x = 160, Delta y = 60 (Intel Endian)*/
    fputc (0x00, fp);
    fputc (0x01, fp);
    fputc (0x32, fp);
    fputc (0x00, fp);

/* Width = 200, Height = 200 (Intel Endian)*/
    fputc (0xc8, fp);
    fputc (0x00, fp);
    fputc (0xc8, fp);
    fputc (0x00, fp);

/* Number of Tuples = 400 */
    fputc (0x90, fp);
    fputc (0x01, fp);
    fputc (0, fp);
    fputc (0, fp);

    for (i = 0; i < 100; i++)
    {
        fputc(100, fp);
        fputc(0, fp);
        fputc(0xff, fp);
        fputc(0x00, fp);
        fputc(100, fp);
        fputc(0, fp);
        fputc(0x03, fp);
        fputc(0x55, fp);
    }
    for (i = 0; i < 100; i++)
    {
        fputc(100, fp);
        fputc(0, fp);
        fputc(0x32, fp);
        fputc(0x13, fp);
        fputc(100, fp);
        fputc(0, fp);
        fputc(0x77, fp);
        fputc(0x77, fp);
    }

/* Number of Alpha Tuples = 400 */
    fputc (0x90, fp);
    fputc (0x01, fp);
    fputc (0, fp);
    fputc (0, fp);

    for (i = 0; i < 400; i++)
    {
        fputc(100, fp);
        fputc(0, fp);
        fputc(0xcf, fp);
    }


/* Fourth Image */
/* Delta x = 240, Delta y = 90 (Intel Endian)*/
    fputc (0x50, fp);
    fputc (0x01, fp);
    fputc (0x5a, fp);
    fputc (0x00, fp);

/* Width = 200, Height = 200 (Intel Endian)*/
    fputc (0xc8, fp);
    fputc (0x00, fp);
    fputc (0xc8, fp);
    fputc (0x00, fp);

/* Number of Tuples = 400 */
    fputc (0x90, fp);
    fputc (0x01, fp);
    fputc (0, fp);
    fputc (0, fp);

    for (i = 0; i < 100; i++)
    {
        fputc(100, fp);
        fputc(0, fp);
        fputc(0x4a, fp);
        fputc(0xda, fp);
        fputc(100, fp);
        fputc(0, fp);
        fputc(0x1d, fp);
        fputc(0x77, fp);
    }
    for (i = 0; i < 100; i++)
    {
        fputc(100, fp);
        fputc(0, fp);
        fputc(0xf0, fp);
        fputc(0x07, fp);
        fputc(100, fp);
        fputc(0, fp);
        fputc(0x00, fp);
        fputc(0x77, fp);
    }

/* Number of Alpha Tuples = 400 */
    fputc (0x90, fp);
    fputc (0x01, fp);
    fputc (0, fp);
    fputc (0, fp);

    for (i = 0; i < 400; i++)
    {
        fputc(100, fp);
        fputc(0, fp);
        fputc(0xcf, fp);
    }

/* Fifth Image */
/* Delta x = 320, Delta y = 120 (Intel Endian)*/
    fputc (0x40, fp);
    fputc (0x01, fp);
    fputc (0x78, fp);
    fputc (0x00, fp);

/* Width = 200, Height = 200 (Intel Endian)*/
    fputc (0xc8, fp);
    fputc (0x00, fp);
    fputc (0xc8, fp);
    fputc (0x00, fp);

/* Number of Tuples = 400 */
    fputc (0x90, fp);
    fputc (0x01, fp);
    fputc (0, fp);
    fputc (0, fp);

    for (i = 0; i < 100; i++)
    {
        fputc(100, fp);
        fputc(0, fp);
        fputc(0xf8, fp);
        fputc(0x1f, fp);
        fputc(100, fp);
        fputc(0, fp);
        fputc(0xff, fp);
        fputc(0xe0, fp);
    }
    for (i = 0; i < 100; i++)
    {
        fputc(100, fp);
        fputc(0, fp);
        fputc(0x07, fp);
        fputc(0xff, fp);
        fputc(100, fp);
        fputc(0, fp);
        fputc(0xff, fp);
        fputc(0xff, fp);
    }

/* Number of Alpha Tuples = 400 */
    fputc (0x90, fp);
    fputc (0x01, fp);
    fputc (0, fp);
    fputc (0, fp);

    for (i = 0; i < 400; i++)
    {
        fputc(100, fp);
        fputc(0, fp);
        fputc(0xcf, fp);
    }





    fclose (fp);
}
