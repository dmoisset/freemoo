#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <ctype.h>

#define MAXCLASSNAMELEN  256

int showa = 0, showi = 0;

void
strupr(char *str) {

    int i = 0;
    while (str[i]) {
        str[i] = toupper(str[i]);
        i++;
    }

}

void
parse (char *filename) {

    char *classname;
    char type;
    char link[MAXCLASSNAMELEN];
    FILE *f;
    
    classname = strdup(filename);
    classname[strlen(classname)-2] = 0;
    strupr(classname);
    
    if (!(f = fopen(filename, "rt"))) {
        fprintf(stderr, "Couldn't open file %s\n", filename);
        exit(1);
    }
    
    fscanf(f, "%c:%s\n", &type, link);    
    while (!feof(f)) {
        strupr(link);
        switch (type) {
            case 'A': if (showa) printf ("\t%s -> %s\n", classname, link); break;
            case 'I': if (showi) printf ("\t%s -> %s [color=\"red\"]\n", link, classname); break;
        }
        fscanf(f, "%c:%s\n", &type, link);        
    }
    
    fclose(f);
    free(classname);

}

int
main(int argc, char **argv) {

    int i, g;
    extern int optind;
    
    while ((g = getopt(argc, argv, "ai")) != -1) {
        switch(g) {
            case 'a': showa = 1; break;
            case 'i': showi = 1; break;
        }
    }

    printf("digraph \"Class associations\" {\n");
    for (i = optind; i < argc; i++)
        parse(argv[i]);
    printf("}\n");

    return 0;

}
