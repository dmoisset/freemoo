TARGETS=background.png connect-button-u.png \
        connect-button-p.png connect-button-d.png
X2P=../../../tools/xcf2png/xcf2png.pl

all: $(TARGETS)
	killall -q gimp || true
	rm -f gimp_active

%.png: %.svg
	sodipodi -z -f $< -e $@

%.png: %.xcf
	make gimp_active
	$(X2P) -filein $< -fileout $@

gimp_active:
	gimp --display :0 -i -c -d -b '(extension-perl-server 1 0 0)' &
	sleep 5
	touch gimp_active