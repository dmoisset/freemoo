SUBDIRS=client
INSTALL_DIR=/usr/local/share/freemoo
INSTALL_TARGETS=$(INSTALL_DIR)/galaxy/starnames.txt \
                $(INSTALL_DIR)/galaxy/sizes \
                $(INSTALL_DIR)/galaxy/stars \
                $(INSTALL_DIR)/galaxy/average/stars \
                $(INSTALL_DIR)/galaxy/orgrich/stars \
                $(INSTALL_DIR)/galaxy/minrich/stars \
                $(INSTALL_DIR)/galaxy/planets \
                $(INSTALL_DIR)/client/connect-window/background.fma \
                $(INSTALL_DIR)/client/connect-window/background.fmi \
                $(INSTALL_DIR)/client/connect-window/connect-button-u.fmi \
                $(INSTALL_DIR)/client/connect-window/connect-button-p.fmi \
                $(INSTALL_DIR)/client/connect-window/connect-button-d.fmi \
                $(INSTALL_DIR)/client/gui/default_font.fmi \
                $(INSTALL_DIR)/client/gui/default_cursor.fmi \
                $(INSTALL_DIR)/client/join-window/background.fmi \
                $(INSTALL_DIR)/client/setup-window/background.fmi \
                $(INSTALL_DIR)/client/main-window/background.fma \
                $(INSTALL_DIR)/client/main-window/game-button.fma \
                $(INSTALL_DIR)/client/main-window/turn-button.fma \
                $(INSTALL_DIR)/client/main-window/colonies-button.fma \
                $(INSTALL_DIR)/client/main-window/planets-button.fma \
                $(INSTALL_DIR)/client/main-window/fleets-button.fma \
                $(INSTALL_DIR)/client/main-window/zoomin-button.fma \
                $(INSTALL_DIR)/client/main-window/zoomout-button.fma \
                $(INSTALL_DIR)/client/main-window/leaders-button.fma \
                $(INSTALL_DIR)/client/main-window/races-button.fma \
                $(INSTALL_DIR)/client/main-window/info-button.fma \
                $(INSTALL_DIR)/client/galaxy-view/star15.fma \
                $(INSTALL_DIR)/client/galaxy-view/star14.fma \
                $(INSTALL_DIR)/client/galaxy-view/star13.fma \
                $(INSTALL_DIR)/client/galaxy-view/star12.fma \
                $(INSTALL_DIR)/client/galaxy-view/star11.fma \
                $(INSTALL_DIR)/client/galaxy-view/star10.fma \
                $(INSTALL_DIR)/client/galaxy-view/star25.fma \
                $(INSTALL_DIR)/client/galaxy-view/star24.fma \
                $(INSTALL_DIR)/client/galaxy-view/star23.fma \
                $(INSTALL_DIR)/client/galaxy-view/star22.fma \
                $(INSTALL_DIR)/client/galaxy-view/star21.fma \
                $(INSTALL_DIR)/client/galaxy-view/star20.fma \
                $(INSTALL_DIR)/client/galaxy-view/star35.fma \
                $(INSTALL_DIR)/client/galaxy-view/star34.fma \
                $(INSTALL_DIR)/client/galaxy-view/star33.fma \
                $(INSTALL_DIR)/client/galaxy-view/star32.fma \
                $(INSTALL_DIR)/client/galaxy-view/star31.fma \
                $(INSTALL_DIR)/client/galaxy-view/star30.fma \
                $(INSTALL_DIR)/client/galaxy-view/star45.fma \
                $(INSTALL_DIR)/client/galaxy-view/star44.fma \
                $(INSTALL_DIR)/client/galaxy-view/star43.fma \
                $(INSTALL_DIR)/client/galaxy-view/star42.fma \
                $(INSTALL_DIR)/client/galaxy-view/star41.fma \
                $(INSTALL_DIR)/client/galaxy-view/star40.fma \
                $(INSTALL_DIR)/client/galaxy-view/star55.fma \
                $(INSTALL_DIR)/client/galaxy-view/star54.fma \
                $(INSTALL_DIR)/client/galaxy-view/star53.fma \
                $(INSTALL_DIR)/client/galaxy-view/star52.fma \
                $(INSTALL_DIR)/client/galaxy-view/star51.fma \
                $(INSTALL_DIR)/client/galaxy-view/star50.fma \
                $(INSTALL_DIR)/client/galaxy-view/star65.fma \
                $(INSTALL_DIR)/client/galaxy-view/star64.fma \
                $(INSTALL_DIR)/client/galaxy-view/star63.fma \
                $(INSTALL_DIR)/client/galaxy-view/star62.fma \
                $(INSTALL_DIR)/client/galaxy-view/star61.fma \
                $(INSTALL_DIR)/client/galaxy-view/star60.fma \
                $(INSTALL_DIR)/client/galaxy-view/star05.fma \
                $(INSTALL_DIR)/client/galaxy-view/star04.fma \
                $(INSTALL_DIR)/client/galaxy-view/star03.fma \
                $(INSTALL_DIR)/client/galaxy-view/star02.fma \
                $(INSTALL_DIR)/client/galaxy-view/star01.fma \
                $(INSTALL_DIR)/client/galaxy-view/star00.fma \
                $(INSTALL_DIR)/client/galaxy-view/background.fma \
                $(INSTALL_DIR)/client/star-view/background.fma \
                $(INSTALL_DIR)/client/star-view/close-button.fma \
                $(INSTALL_DIR)/client/star-view/orbit1.fma\
                $(INSTALL_DIR)/client/star-view/orbit2.fma\
                $(INSTALL_DIR)/client/star-view/orbit3.fma\
                $(INSTALL_DIR)/client/star-view/orbit4.fma\
                $(INSTALL_DIR)/client/star-view/orbit5.fma\
                $(INSTALL_DIR)/client/star-view/sun1.fma\
                $(INSTALL_DIR)/client/star-view/sun2.fma\
                $(INSTALL_DIR)/client/star-view/sun3.fma\
                $(INSTALL_DIR)/client/star-view/sun4.fma\
                $(INSTALL_DIR)/client/star-view/sun5.fma\
                $(INSTALL_DIR)/client/star-view/sun6.fma


all: $(SUBDIRS)

.PHONY: $(SUBDIRS)

$(SUBDIRS):
	$(MAKE) -C $@

install: $(INSTALL_TARGETS)

$(INSTALL_DIR)/%: %
	install -d -m 0755 -o root -g root `dirname $@`
	install -m 0644 -o root -g root $< $@
