SRC1 = test_load_img.c ../../client/src/C/img_loader.c

SRC2 = test_load_anim.c ../../client/src/C/img_loader.c

OBJ1 = test_load_img.o ../../client/src/C/img_loader.o

OBJ2 = test_load_anim.o ../../client/src/C/img_loader.o

PROG1 = test_load_img

PROG2 = test_load_anim

CFLAGS = -ansi -pedantic -Wall -g -O2 `sdl-config --cflags`
LDFLAGS = `sdl-config --libs`

all: .depend $(PROG1) $(PROG2)

$(PROG1): $(OBJ1)
	$(CC) $(CFLAGS) $(LDFLAGS) -o $@ $^

$(PROG2): $(OBJ2)
	$(CC) $(CFLAGS) $(LDFLAGS) -o $@ $^

clean:
	rm -f $(OBJ1) $(OBJ2) $(PROG1) $(PROG2)

distclean: clean
	rm -f .depend *~

.depend: $(SRC1) $(SRC2)
	$(CC) -M $(CFLAGS) $(SRC1) > .depend
	$(CC) -M $(CFLAGS) $(SRC2) >> .depend

.PHONY: clean distclean

-include .depend
