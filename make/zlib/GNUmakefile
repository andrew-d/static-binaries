include config.mk

ZLIB_VERSION := 1.2.8
ZLIB_DIR := $(BUILD_DIR)/zlib-$(ZLIB_VERSION)

.PHONY: zlib.lib
zlib.lib: $(ZLIB_DIR)/libz.a

##################################################

# Fetch the source
$(BUILD_DIR)/zlib-$(ZLIB_VERSION).tar.gz: | $(BUILD_DIR)
	$(Q)curl -sL -o $@ http://zlib.net/zlib-$(ZLIB_VERSION).tar.gz

# Untar
$(BUILD_DIR)/zlib-untar-stamp: $(BUILD_DIR)/zlib-$(ZLIB_VERSION).tar.gz
	$(Q)tar zxf $< -C $(BUILD_DIR)
	$(Q)touch $@

# Run configure
$(BUILD_DIR)/zlib-configure-stamp: $(BUILD_DIR)/zlib-untar-stamp
	$(Q)cd $(ZLIB_DIR) && \
		CHOST=$(CROSS_PREFIX)				\
		CC='$(CC) $(STATIC_FLAG)'			\
		CFLAGS='-fPIC' 						\
		./configure 						\
			--static
	$(Q)touch $@

$(ZLIB_DIR)/libz.a: $(BUILD_DIR)/zlib-configure-stamp
	$(Q)$(MAKE) -C $(ZLIB_DIR)

.PHONY: zlib.clean
zlib.clean:
	-$(Q)$(MAKE) -C $(ZLIB_DIR) clean
	-$(Q)$(RM) $(BUILD_DIR)/zlib-*-stamp $(BUILD_DIR)/zlib-$(ZLIB_VERSION).tar.gz
	-$(Q)$(RM) -r $(ZLIB_DIR)


##################################################

# Set the appropriate flags to link with this library.
ZLIB_CFLAGS :=
ZLIB_CPPFLAGS := -I$(ZLIB_DIR)
ZLIB_CXXFLAGS :=
ZLIB_LDFLAGS := -L$(ZLIB_DIR) -lz
