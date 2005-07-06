TARGETS= mpview palview

all: $(TARGETS)

clean:
	rm -f $(TARGETS)

%: %.pp
	ppc386  -Fu/usr/lib/fpc/1.0.6/units/linux/SDL4Freepascal-1.2.0.0/ $<