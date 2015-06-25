include config.mk

SOCAT_VERSION := 1.7.3.0
SOCAT_DIR := $(BUILD_DIR)/socat-$(SOCAT_VERSION)

.PHONY: socat.bin socat.install
socat.bin: $(SOCAT_DIR)/socat
socat.install: $(OUT_DIR)/socat-$(PLATFORM)-$(ARCH)

##################################################

# Fetch the source
$(BUILD_DIR)/socat-$(SOCAT_VERSION).tar.gz: | $(BUILD_DIR)
	$(Q)curl -sL -o $@ http://www.dest-unreach.org/socat/download/socat-$(SOCAT_VERSION).tar.gz

# Untar
$(BUILD_DIR)/socat-untar-stamp: $(BUILD_DIR)/socat-$(SOCAT_VERSION).tar.gz
	$(Q)tar zxf $< -C $(BUILD_DIR)
	$(Q)touch $@

# Run configure
$(BUILD_DIR)/socat-configure-stamp: $(BUILD_DIR)/socat-untar-stamp ncurses.lib readline.lib openssl.lib
	$(Q)cd $(SOCAT_DIR) && \
		CC=$(CC) \
		CXX=$(CXX) \
		CFLAGS='$(STATIC_FLAG) $(NCURSES_CFLAGS) $(READLINE_CFLAGS) $(OPENSSL_CFLAGS)' \
		CXXFLAGS='$(STATIC_FLAG) $(NCURSES_CXXFLAGS) $(READLINE_CXXFLAGS) $(OPENSSL_CXXFLAGS)' \
		CPPFLAGS='-DNETDB_INTERNAL=-1 $(NCURSES_CPPFLAGS) $(READLINE_CPPFLAGS) $(OPENSSL_CPPFLAGS)' \
		LDFLAGS='$(NCURSES_LDFLAGS) $(READLINE_LDFLAGS) $(OPENSSL_LDFLAGS)' \
		./configure 				\
			--build=i686 			\
			--host=$(CROSS_PREFIX)
	$(Q)touch $@

$(SOCAT_DIR)/socat: $(BUILD_DIR)/socat-configure-stamp
	$(Q)$(MAKE) -C $(SOCAT_DIR)

$(OUT_DIR)/socat-$(PLATFORM)-$(ARCH): $(SOCAT_DIR)/socat | $(OUT_DIR)
	$(Q)cp $< $@
	$(Q)$(STRIP) $@

.PHONY: socat.clean
socat.clean:
	-$(Q)$(MAKE) -C $(SOCAT_DIR) clean
	-$(Q)$(RM) $(BUILD_DIR)/socat-*-stamp $(BUILD_DIR)/socat-$(SOCAT_VERSION).tar.gz
	-$(Q)$(RM) -r $(SOCAT_DIR)


##################################################
