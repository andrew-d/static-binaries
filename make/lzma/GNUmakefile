include config.mk

LZMA_VERSION := 5.0.8
LZMA_DIR := $(BUILD_DIR)/xz-$(LZMA_VERSION)

.PHONY: lzma.lib
lzma.lib: $(LZMA_DIR)/src/liblzma/.libs/liblzma.a

##################################################

# Fetch the source
$(BUILD_DIR)/lzma-$(LZMA_VERSION).tar.gz: | $(BUILD_DIR)
	$(Q)curl -sL -o $@ http://tukaani.org/xz/xz-$(LZMA_VERSION).tar.gz

# Untar
$(BUILD_DIR)/lzma-untar-stamp: $(BUILD_DIR)/lzma-$(LZMA_VERSION).tar.gz
	$(Q)tar zxf $< -C $(BUILD_DIR)
	$(Q)touch $@

# Run configure
$(BUILD_DIR)/lzma-configure-stamp: $(BUILD_DIR)/lzma-untar-stamp
	$(Q)cd $(LZMA_DIR) && \
		CC=$(CC) 					\
		CXX=$(CXX) 					\
		CFLAGS='$(STATIC_FLAG)'		\
		./configure 				\
			--disable-shared		\
			--enable-static			\
			--host=$(CROSS_PREFIX)	\
			--build=i686
	$(Q)touch $@

$(LZMA_DIR)/src/liblzma/.libs/liblzma.a: $(BUILD_DIR)/lzma-configure-stamp
	$(Q)$(MAKE) -C $(LZMA_DIR)

.PHONY: lzma.clean
lzma.clean:
	-$(Q)$(MAKE) -C $(LZMA_DIR) clean
	-$(Q)$(RM) $(BUILD_DIR)/lzma-*-stamp $(BUILD_DIR)/lzma-$(LZMA_VERSION).tar.gz
	-$(Q)$(RM) -r $(LZMA_DIR)


##################################################

# Set the appropriate flags to link with this library.
LZMA_CFLAGS :=
LZMA_CPPFLAGS := -I$(LZMA_DIR)/src/liblzma/api
LZMA_CXXFLAGS :=
LZMA_LDFLAGS := -L$(LZMA_DIR)/src/liblzma/.libs -llzma
