TARGETS=background.png connect-button-u.png \
        connect-button-p.png connect-button-d.png
X2P=../../../tools/xcf2png/xcf2png.pl

all: $(TARGETS)

%.png: %.xcf
	$(X2P) -filein $< -fileout $@

