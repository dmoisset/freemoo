TARGET=server
SOURCEFILES=src/*.e ../shared/*.e
EIFFLAGS=-case_insensitive -high_memory_compiler
LIBS=-leifinet
# Building commands: BUILD1; BUILD2 should build the system
BUILD1=compile -O0
BUILD2=true

# Adapt to host environment. Resistance is futile
-include Makefile.$(HOSTNAME)

all: $(TARGET)

$(TARGET): $(SOURCEFILES)
	$(BUILD1) -o $(TARGET) $(TARGET) $(EIFFLAGS) $(LIBS)
	$(BUILD2) -o $(TARGET) $(TARGET).c $(LIBS)

check: $(SOURCEFILES)
	compile_to_c $(TARGET) $(EIFFLAGS)

clean:
	rm -f $(TARGET)
	clean $(TARGET)
        