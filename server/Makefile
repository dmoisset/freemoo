TARGET=server
SOURCEFILES=src/*.e ../shared/*.e

EIFFLAGS=-case_insensitive -high_memory_compiler -cc tcc
LIBS=-leifinet

all: $(TARGET)

$(TARGET): $(SOURCEFILES)
	compile $(TARGET) -o $(TARGET) $(EIFFLAGS) $(LIBS)

check: $(SOURCEFILES)
	compile_to_c $(TARGET) $(EIFFLAGS)

clean:
	rm -f $(TARGET)
	clean $(TARGET)
        