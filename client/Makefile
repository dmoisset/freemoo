EIFFLAGS=-cecil $(VEGTK)/VEGTK/cecil.se -case_insensitive -cc tcc
TARGET=fm_client
LIBS=-L$(VEGTK)/VEGTK/gtk/C -L$(VEGTK)/VEGTK/gdk/C -L$(VEGTK)/VEGTK/support/C \
     -lvegtk -lvegdk -lvegtksup \
     `gtk-config --libs|sed s/-rdynamic//` -leifinet
TARGET2=dumb_client
LIBS2=-leifinet
SOURCEFILES=src/*.e ../shared/*.e

all: $(TARGET) $(TARGET2)

$(TARGET): $(SOURCEFILES) gtk_interface
	compile -o $(TARGET) $(TARGET) $(EIFFLAGS) $(LIBS)

$(TARGET2): $(SOURCEFILES)
	compile -o $(TARGET2) $(TARGET2) $(EIFFLAGS) $(LIBS2)

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
