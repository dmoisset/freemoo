TARGET=test_map_generator
SOURCEFILES=*.e

EIFFLAGS=-case_insensitive -high_memory_compiler
LIBS=-L$(JEGL)/C -ljegl -lSDL_image `sdl-config --libs` -L/usr/X11R6/lib

all: $(TARGET)
	compile_to_c $(TARGET) $(EIFFLAGS)
	tcc -o $(TARGET) $(TARGET)*.c $(LIBS)

$(TARGET): $(SOURCEFILES)

check: $(SOURCEFILES)
	compile_to_c $(TARGET)

clean:
	rm -f $(TARGET)
	clean $(TARGET)
