#include <stdio.h>
#include <malloc.h>
#include <string.h>
#include <unistd.h>
#include <ctype.h>
#include <stdlib.h>

/*we assume lowercase filenames*/

#define MAXLINKS 256
#define MAXCLASSNAMELEN 256

char lista[MAXLINKS][MAXCLASSNAMELEN];
int lc = 0;

extern char *strdup (char *);

void
strlwr(char *str) {

    int i = 0;
    while (str[i]) {
        str[i] = tolower(str[i]);
        i++;
    }

}

void
init(char *classname) {

     lc = 1;
     strcpy(lista[0], classname);
     strlwr(lista[0]);

}

int
buscar(char *classname) {
/*classname must be lowercase*/

    int i;

    for (i = 0; i < lc; i++)
        if (strcmp(classname, lista[i]) == 0)
            return 1;
    return 0;

}

void
agregar(char *classname) {

     strcpy(lista[lc], classname);
     strlwr(lista[lc]);
     lc++;
     
     if (lc >= MAXLINKS) {
        fprintf(stderr, "Maximum number of links exceeded\n");
        exit(1);
     }

}

int
exists(char *classname) {

    char *filename;
    int ex;
    
    filename = malloc(strlen(classname)+3);
    strcpy(filename, classname);
    strcat(filename, ".e");
    ex = !access(filename, F_OK);
    free(filename);
    
    return ex;

}

char *
filename_to_classname(char *filename) {
/*must be freed*/

    char *name;
    
    name = strdup(filename);
    name[strlen(name)-2] = '\0';
    
    return name;

}

int
valid_classname(char *classname) {
/*valid means alphanumeric & _ (no digits)*/

    int pos = 0;
    
    while (classname[pos]) {
        if (!isupper(classname[pos]) && classname[pos] != '_')
            break;
        pos++;
    }
    
    return !classname[pos];

}

void
parse(char *filename) {

     int mode = 0; /*1 para inherited, 2 para associations*/
     char lectura[256]; /*maximum length of any word in source code must be <= 255*/
     char *classname;
     FILE *i, *o;

     printf("Parsing %s\n", filename);

     if (!(i = fopen(filename, "rt"))) {
        fprintf(stderr, "Couldn't read file %s\n", filename);
        exit(1);
     }
     
     filename[strlen(filename)-1] = 'g';
     o = fopen(filename, "wt");
     filename[strlen(filename)-1] = 'e';

     classname = filename_to_classname(filename);
     
     fscanf(i, "%s", lectura);
     while (!feof(i)) {

          if (mode < 1 && strcmp(lectura, "inherit") == 0) {
             init(classname);
             mode = 1;
          } else if (mode < 2 && strcmp(lectura, "feature") == 0) {
             init(classname);
             mode = 2;
          } else {
    
             /*remove trailing ; and )*/
             if (lectura[strlen(lectura)-1] == ';')
                lectura[strlen(lectura)-1] = '\0';
             if (lectura[strlen(lectura)-1] == ')')
                lectura[strlen(lectura)-1] = '\0';

             if (valid_classname(lectura)) {
                strlwr(lectura);
                if (exists(lectura) && !buscar(lectura)) {
                    agregar(lectura);
                    switch (mode) {
                        case 1: fprintf(o, "I:%s\n", lectura); break;
                        case 2: fprintf(o, "A:%s\n", lectura); break;
                    }
                }
             }
             
          }
          
          fscanf(i, "%s", lectura);
     
     }

     free(classname);
     fclose(o);
     fclose(i);

}

int
main(int argc, char **argv) {

    int i;
    
    for (i = 1; i < argc; i++)
        parse(argv[i]);

    return 0;

}
