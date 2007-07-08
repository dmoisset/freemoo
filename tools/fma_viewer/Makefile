ifndef SmartEiffelDirectory
SmartEiffelDirectory=$(shell dirname $(shell dirname $(SmartEiffel)))
endif

include ../../config
export SEDIR:=$(shell echo $(SEDIR))

TARGET=fma_viewer
SOURCEFILES=*.e ../../client/src/*anim*.e
EIFFLAGS=-high_memory_compiler
LIBS=-lSDL_image `sdl-config --cflags --libs` -I../../client\
     -lews-SDL -lSDL_ttf ../../client/src/C/img_loader.o

all: $(TARGET)

$(TARGET): $(SOURCEFILES)
	compile $(TARGET) -o $(TARGET) $(EIFFLAGS) $(LIBS)

check: $(SOURCEFILES)
	compile_to_c $(TARGET) $(EIFFLAGS) $(LIBS)

clean:
	rm -f $(TARGET)
	clean $(TARGET)
        