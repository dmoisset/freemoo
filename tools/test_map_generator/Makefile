TARGET=test_map_generator
SOURCEFILES=*.e
EIFFLAGS=-case_insensitive -high_memory_compiler
LIBS=-L$(JEGL)/C -ljegl -lSDL_image `sdl-config --libs`
# Building commands: BUILD1; BUILD2 should build the system
BUILD1=compile -O0
BUILD2=true

# Adapt to host environment. Resistance is futile
-include Makefile.$(HOSTNAME)

all: $(TARGET)
	$(BUILD1) -o $(TARGET) $(TARGET) $(EIFFLAGS) $(LIBS)
	$(BUILD2) -o $(TARGET) $(TARGET).c $(LIBS)

$(TARGET): $(SOURCEFILES)

check: $(SOURCEFILES)
	compile_to_c $(TARGET)

clean:
	rm -f $(TARGET)
	clean $(TARGET)
