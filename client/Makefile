EIFFLAGS=-cecil $(VEGTK)/VEGTK/cecil.se -case_insensitive
LIBS=-L$(VEGTK)/VEGTK/gtk/C -L$(VEGTK)/VEGTK/gdk/C -L$(VEGTK)/VEGTK/support/C \
     -lvegtk -lvegdk -lvegtksup `gtk-config --libs` -leifinet
TARGET=fm_client
TARGET2=dumb_client
LIBS2=-leifinet
SOURCEFILES=src/*.e ../shared/*.e
# Building commands: BUILD1; BUILD2 should build the system
BUILD1=compile -O0
BUILD2=true

# Adapt to host environment. Resistance is futile
-include Makefile.$(HOSTNAME)

all: $(TARGET) $(TARGET2)

$(TARGET): $(SOURCEFILES) gtk_interface
	$(BUILD1) -o $(TARGET) $(TARGET) $(EIFFLAGS) $(LIBS)
	$(BUILD2) -o $(TARGET) $(TARGET).c $(LIBS)

$(TARGET2): $(SOURCEFILES)
	$(BUILD1) -o $(TARGET2) $(TARGET2) $(EIFFLAGS) $(LIBS2)
	$(BUILD2) -o $(TARGET2) $(TARGET2).c $(LIBS2)

check: $(SOURCEFILES)
	veglade gui.glade
	compile_to_c $(TARGET) $(EIFFLAGS)
	compile_to_c $(TARGET2) $(EIFFLAGS)

clean:
	rm -f $(TARGET) $(TARGET2) gtk_interface cecil.h
	clean $(TARGET)
	clean $(TARGET2)

gtk_interface: gui.glade
	touch gtk_interface
	veglade gui.glade
