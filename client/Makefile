EIFFLAGS=-cecil $(VEGTK)/VEGTK/cecil.se -case_insensitive -cc tcc
LIBS=-L$(VEGTK)/VEGTK/gtk/C -L$(VEGTK)/VEGTK/gdk/C -L$(VEGTK)/VEGTK/support/C \
     -lvegtk -lvegdk -lvegtksup \
     `gtk-config --libs|sed s/-rdynamic//` -leifinet
TARGET=fm_client
SOURCEFILES=src/*.e ../shared/*.e ../netservices/*.e

all: $(TARGET)

$(TARGET): $(SOURCEFILES) gtk_interface
	compile $(TARGET) -o $(TARGET) $(EIFFLAGS) $(LIBS)

check: $(SOURCEFILES)
	veglade gui.glade
	compile_to_c $(TARGET) $(EIFFLAGS)

clean:
	rm -f $(TARGET) gtk_interface
	clean $(TARGET)

gtk_interface: gui.glade
	touch gtk_interface
	veglade gui.glade
