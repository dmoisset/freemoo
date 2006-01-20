TARGET=server
SOURCEFILES=src/*.e ../shared/*.e ../shared/constructions/*.e
EIFFLAGS=-case_insensitive -high_memory_compiler
LIBS=-leifinet

include ../config
export SEDIR:=$(shell echo $(SEDIR))

all: $(TARGET)

$(TARGET): $(SOURCEFILES)
	compile -o $(TARGET) $(TARGET) $(EIFFLAGS) $(LIBS)

check: $(SOURCEFILES)
	compile_to_c $(TARGET) $(EIFFLAGS)

.PHONY: clean

clean:
	rm -f $(TARGET)
	clean $(TARGET)
        