TARGET=server
SOURCEFILES=src/*.e ../shared/*.e
EIFFLAGS=-case_insensitive -high_memory_compiler
LIBS=-leifinet

all: $(TARGET)

$(TARGET): $(SOURCEFILES)
	compile -o $(TARGET) $(TARGET) $(EIFFLAGS) $(LIBS)

check: $(SOURCEFILES)
	compile_to_c $(TARGET) $(EIFFLAGS)

clean:
	rm -f $(TARGET)
	clean $(TARGET)
        