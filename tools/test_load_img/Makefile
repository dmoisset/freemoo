SRC = test_load_img.c ../../client/src/C/img_loader.c

OBJ = test_load_img.o ../../client/src/C/img_loader.o

PROG = test_load_img

CFLAGS = -Wall -g -O2 `sdl-config --cflags`
LDFLAGS = `sdl-config --libs`

all: .depend $(PROG)

$(PROG): $(OBJ)
	$(CC) $(CFLAGS) $(LDFLAGS) -o $@ $^

clean:
	rm -f $(OBJ) $(PROG)

distclean: clean
	rm -f .depend *~

.depend: $(SRC)
	$(CC) -M $(CFLAGS) $(SRC) > .depend

.PHONY: clean distclean

-include: .depend
