#include <stdlib.h>
#include <string.h>

char *strdup (char *str) {

	char *s = (char *) malloc(strlen(str)+1);
	strcpy(s, str);
	return s;

}
