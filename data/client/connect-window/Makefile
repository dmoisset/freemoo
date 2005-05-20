TARGETS=background.fmi connect-button-u.fmi \
        connect-button-p.fmi connect-button-d.fmi
X2P=../../../tools/xcf2png/xcf2png.pl
P2F=../../../tools/png2fmi/png2fmi

all: $(TARGETS)
	killall -q gimp || true
	rm -f gimp_active

%.fmi: %.png
	$(P2F) -r $< $@

%.png: %.svg
	sodipodi -z -f $< -e $@

%.png: %.xcf
	make gimp_active
	$(X2P) -filein $< -fileout $@

gimp_active:
	gimp --display :0 -i -c -d -b '(extension-perl-server 1 0 0)' &
	sleep 5
	touch gimp_active