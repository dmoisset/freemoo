EIFFLAGS=-case_insensitive
TARGET=fm_client
SmartEiffelDirectory=$(shell dirname $(shell dirname $(SmartEiffel)))
CLIBS=src/C/net_thread.o src/C/img_loader.o
LIBS=`sdl-config --cflags --libs` $(CLIBS)\
     -lews-SDL -leifinet
TARGET2=dumb_client
LIBS2=-leifinet
SOURCEFILES=src/*.e ../shared/*.e src/screens/*.e src/widgets/*.e \
            src/views/*.e src/C/*.c ../shared/constructions/*.e

all: $(TARGET) $(TARGET2)

$(TARGET): $(SOURCEFILES) $(CLIBS)
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
