EIFFLAGS=
TARGET=fm_client
ifndef SmartEiffelDirectory
SmartEiffelDirectory=$(shell dirname $(shell dirname $(SmartEiffel)))
endif

CLIBS=src/C/net_thread.o src/C/img_loader.o
LIBS=`sdl-config --cflags --libs` $(CLIBS)\
     -lews-SDL -leifinet -lSDL_ttf
TARGET2=dumb_client
LIBS2=-leifinet
SOURCEFILES=src/*.e ../shared/*.e src/screens/*.e src/widgets/*.e \
            src/views/*.e src/C/*.c ../shared/constructions/*.e \
            ../shared/technology/*.e

include ../config
export SEDIR:=$(shell echo $(SEDIR))

all: $(TARGET) $(TARGET2)

$(TARGET): $(SOURCEFILES) $(CLIBS) ../config
	compile -o $(TARGET) $(TARGET) $(EIFFLAGS) $(LIBS)

$(TARGET2): $(SOURCEFILES)
	compile -o $(TARGET2) $(TARGET2) $(EIFFLAGS) $(LIBS2)

$(CLIBS):
	$(MAKE) -C `dirname $@`

check: $(SOURCEFILES)
	compile_to_c $(TARGET) $(EIFFLAGS)
	compile_to_c $(TARGET2) $(EIFFLAGS)

.PHONY: clean

clean:
	rm -f $(TARGET) $(TARGET2)
	clean $(TARGET)
	clean $(TARGET2)
