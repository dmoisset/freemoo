#ifndef MISC_H
#define MISC_H

/*  versiones añejas de gcc (libc4, libc5) no tienen hints al
    compilador via la macro __attribute__ */
#ifndef __attribute__
#define __attribute__(x) /* */
#endif

int streq(const char * a, const char *b);

/*@exits@*/
void die(const char* template, ...)
     __attribute__ ((__format__ (printf, 1, 2)))
     __attribute__ ((__noreturn__));


#ifndef NDEBUG
void debug(const char* template, ...)
     __attribute__ ((__format__ (printf, 1, 2)));
#else
#define debug(template...) ;
#endif

#endif /* MISC_H */
