SUBDIRS=client
INSTALL_DIR=/usr/local/share/freemoo
INSTALL_TARGETS=$(INSTALL_DIR)/galaxy/starnames.txt \
                $(INSTALL_DIR)/galaxy/sizes \
                $(INSTALL_DIR)/galaxy/stars \
                $(INSTALL_DIR)/galaxy/average/stars \
                $(INSTALL_DIR)/galaxy/orgrich/stars \
                $(INSTALL_DIR)/galaxy/minrich/stars \
                $(INSTALL_DIR)/galaxy/planets \
                $(INSTALL_DIR)/client/connect-window/background.png \
                $(INSTALL_DIR)/client/connect-window/connect-button-u.png \
                $(INSTALL_DIR)/client/connect-window/connect-button-p.png \
                $(INSTALL_DIR)/client/connect-window/connect-button-d.png \
                $(INSTALL_DIR)/client/gui/default_font.png \
                $(INSTALL_DIR)/client/gui/default_cursor.png \
                $(INSTALL_DIR)/client/join-window/background.png \
                $(INSTALL_DIR)/client/setup-window/background.png \


all: $(SUBDIRS)

$(SUBDIRS):
	$(MAKE) -C $@

install: $(INSTALL_TARGETS)

$(INSTALL_DIR)/%: %
	install -d -m 0755 -o root -g root `dirname $@`
	install -m 0644 -o root -g root $< $@
