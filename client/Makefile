EIFFLAGS=-case_insensitive -cc tcc
TARGET=fm_client
SmartEiffelDirectory=$(shell dirname $(shell dirname $(SmartEiffel)))
LIBS=-lSDL_image `sdl-config --libs` src/C/net_thread.o \
     $(SmartEiffelDirectory)/lib_ews/driver-sdl/C/driver-sdl.o -leifinet
TARGET2=dumb_client
LIBS2=-leifinet
SOURCEFILES=src/*.e ../shared/*.e src/screens/*.e src/widgets/*.e \
            src/views/*.e src/C/*.c

all: $(TARGET) $(TARGET2)

$(TARGET): $(SOURCEFILES)
	compile -o $(TARGET) $(TARGET) $(EIFFLAGS) $(LIBS)

$(TARGET2): $(SOURCEFILES)
	compile -o $(TARGET2) $(TARGET2) $(EIFFLAGS) $(LIBS2)

check: $(SOURCEFILES)
	compile_to_c $(TARGET) $(EIFFLAGS)
	compile_to_c $(TARGET2) $(EIFFLAGS)

clean:
	rm -f $(TARGET) $(TARGET2)
	clean $(TARGET)
	clean $(TARGET2)
