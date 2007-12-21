ifndef SmartEiffelDirectory
SmartEiffelDirectory=$(shell dirname $(shell dirname $(SmartEiffel)))
endif

TARGET1=template_maker
TARGET2=model_maker
SOURCEFILES=*.e ../../client/src/*anim*.e
EIFFLAGS=-high_memory_compiler
LIBS=-lSDL_image -lSDL_ttf `sdl-config --cflags --libs` -I../../client\
     $(SmartEiffelDirectory)/lib_ews/driver-sdl/C/driver-sdl.o ../../client/src/C/img_loader.o

all: $(TARGET1) $(TARGET2)

template: $(TARGET1)

model: $(TARGET2)

$(TARGET1): $(SOURCEFILES)
	compile $(TARGET1) -o $(TARGET1) $(EIFFLAGS) $(LIBS)

$(TARGET2): $(SOURCEFILES)
	compile $(TARGET2) -o $(TARGET2) $(EIFFLAGS) $(LIBS)

clean:
	rm -f $(TARGET1) $(TARGET2)
	clean $(TARGET1) $(TARGET2)
