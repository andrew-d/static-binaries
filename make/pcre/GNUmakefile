include config.mk

PCRE_VERSION := 8.37
PCRE_DIR := $(BUILD_DIR)/pcre-$(PCRE_VERSION)

.PHONY: pcre.lib
pcre.lib: $(PCRE_DIR)/.libs/libpcre.a

##################################################

# Fetch the source
$(BUILD_DIR)/pcre-$(PCRE_VERSION).tar.gz: | $(BUILD_DIR)
	$(Q)curl -sL -o $@ ftp://ftp.csx.cam.ac.uk/pub/software/programming/pcre/pcre-$(PCRE_VERSION).tar.gz

# Untar
$(BUILD_DIR)/pcre-untar-stamp: $(BUILD_DIR)/pcre-$(PCRE_VERSION).tar.gz
	$(Q)tar zxf $< -C $(BUILD_DIR)
	$(Q)touch $@

# Run configure
$(BUILD_DIR)/pcre-configure-stamp: $(BUILD_DIR)/pcre-untar-stamp
	$(Q)cd $(PCRE_DIR) && \
		CC=$(CC) 					\
		CXX=$(CXX) 					\
		CFLAGS='$(STATIC_FLAG)'		\
		CXXFLAGS='$(STATIC_FLAG)'	\
		./configure 				\
			--disable-shared		\
			--enable-static			\
			--host=$(CROSS_PREFIX)	\
			--build=i686
	$(Q)touch $@

$(PCRE_DIR)/.libs/libpcre.a: $(BUILD_DIR)/pcre-configure-stamp
	$(Q)$(MAKE) -C $(PCRE_DIR)

.PHONY: pcre.clean
pcre.clean:
	-$(Q)$(MAKE) -C $(PCRE_DIR) clean
	-$(Q)$(RM) $(BUILD_DIR)/pcre-*-stamp $(BUILD_DIR)/pcre-$(PCRE_VERSION).tar.gz
	-$(Q)$(RM) -r $(PCRE_DIR)


##################################################

# Set the appropriate flags to link with this library.
PCRE_CFLAGS :=
PCRE_CPPFLAGS := -I$(PCRE_DIR)
PCRE_CXXFLAGS :=
PCRE_LDFLAGS := -L$(PCRE_DIR)/.libs -lpcre
