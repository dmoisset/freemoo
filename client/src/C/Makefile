TARGETS=img_loader.o net_thread.o
CC=gcc
CFLAGS=-Wall -pedantic -ansi
#Should work with -ansi

all: $(TARGETS)

%.o: %.c
	$(CC) $(CFLAGS) -c $<

img_loader.o: img_loader.h

clean:
	rm -f $(TARGETS)