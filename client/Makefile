EIFFLAGS=-cecil $(VEGTK)/VEGTK/cecil.se -case_insensitive
LIBS=-L$(VEGTK)/VEGTK/gtk/C -L$(VEGTK)/VEGTK/gdk/C -L$(VEGTK)/VEGTK/support/C \
     -lvegtk -lvegdk -lvegtksup `gtk-config --libs` -leifinet
TARGET=fm_client
SOURCEFILES=src/*.e ../shared/*.e
# Building commands: BUILD1; BUILD2 should build the system
BUILD1=compile -O0
BUILD2=true

# Adapt to host environment. Resistance is futile
-include Makefile.$(HOSTNAME)

all: $(TARGET)

$(TARGET): $(SOURCEFILES) gtk_interface
	$(BUILD1) -o $(TARGET) $(TARGET) $(EIFFLAGS) $(LIBS)
	$(BUILD2) -o $(TARGET) $(TARGET).c $(LIBS)

dumb_client: $(SOURCEFILES)
	$(BUILD1) -o dumb_client dumb_client $(EIFFLAGS) -leifinet
	$(BUILD2) -o dumb_client dumb_client.c -leifinet

check: $(SOURCEFILES)
	veglade gui.glade
	compile_to_c $(TARGET) $(EIFFLAGS)

clean:
	rm -f $(TARGET) gtk_interface cecil.h
	clean $(TARGET)

gtk_interface: gui.glade
	touch gtk_interface
	veglade gui.glade
