#include <stdio.h>
#include <stdarg.h>
#include <errno.h>
#include <unistd.h>
#include <stdlib.h>

#include "misc.h"

void die(const char* template, ...)
{
     char* msg;
     va_list ap;

     va_start(ap, template);
     vasprintf(&msg, template, ap);
     va_end(ap);

     if (errno)
          perror(msg);
     else
          printf("%s\n", msg);
     exit(1);
}

#ifndef NDEBUG
void debug(const char* template, ...)
{
     static FILE *f = 0;
     char *str = 0;
     va_list ap;

     asprintf(&str, "[%d] %s\n", getpid(), template);

     if (f==0)
     {
         int n = dup(fileno(stderr));
         if (n==-1)
             die("Unable to dup stder");
         f = fdopen(n, "w");
         if (!f)
             die("Unable to fdopen stderr's dup");
     }

     va_start(ap, template);
     vfprintf(f, str, ap);
     va_end(ap);

     free(str);
}
#endif

int streq(const char * a, const char *b)
{
    int i;

    for (i=0; a[i] && b[i] && a[i] == b[i]; i++);

    if (a[i] == b[i])
        return 0;
    else if (a[i] > b[i])
        return 1;
    else
        return -1;
}
