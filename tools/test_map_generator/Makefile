SmartEiffelDirectory=$(shell dirname $(shell dirname $(SmartEiffel)))
TARGET=test_map_generator
TARGET2=test_map_generator_v2
SOURCEFILES=*.e ../../shared/*.e
SOURCEFILES2=*.e ../../shared/*.e ../../client/src/views/*.e
EIFFLAGS=-case_insensitive -high_memory_compiler
LIBS=-L$(JEGL)/C -ljegl -lSDL_image `sdl-config --libs` -I../../client \
     $(SmartEiffelDirectory)/lib_ews/driver-sdl/C/driver-sdl.o ../../client/src/C/img_loader.o

all: $(TARGET) $(TARGET2)

$(TARGET): $(SOURCEFILES)
	compile -o $@ $@ $(EIFFLAGS) $(LIBS)

$(TARGET2): $(SOURCEFILES2)
	compile -o $@ $@ $(EIFFLAGS) $(LIBS)

check: $(SOURCEFILES)
	compile_to_c $(TARGET)
	compile_to_c $(TARGET2)

clean:
	rm -f $(TARGET) $(TARGET2)
	clean $(TARGET)
	clean $(TARGET2)
