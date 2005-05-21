TARGETS=unlbx mergepal
# Extra targets. Useful to develop, but not needed for compilation
XTARGETS= mpview palview

include ../config

all: $(TARGETS)
extra: $(XTARGETS)

unlbx: unlbx.ace *.e
	$(SECOMPILE) $<
	strip $@
        
clean:
	clean $(TARGETS)
	rm -f $(TARGETS) $(XTARGETS)

%: %.pp
	ppc386  -Fu/usr/lib/fpc/1.0.6/units/linux/SDL4Freepascal-1.2.0.0/ $<