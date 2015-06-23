include config.mk

TERMCAP_VERSION := 1.3.1
TERMCAP_DIR := $(BUILD_DIR)/termcap-$(TERMCAP_VERSION)

.PHONY: termcap.lib
termcap.lib: $(TERMCAP_DIR)/libtermcap.a

##################################################

# Fetch the source
$(BUILD_DIR)/termcap-$(TERMCAP_VERSION).tar.gz: | $(BUILD_DIR)
	$(Q)curl -sL -o $@ http://ftp.gnu.org/gnu/termcap/termcap-$(TERMCAP_VERSION).tar.gz

# Untar
$(BUILD_DIR)/termcap-untar-stamp: $(BUILD_DIR)/termcap-$(TERMCAP_VERSION).tar.gz
	$(Q)tar zxf $< -C $(BUILD_DIR)
	$(Q)touch $@

# Run configure
$(BUILD_DIR)/termcap-configure-stamp: $(BUILD_DIR)/termcap-untar-stamp
	$(Q)cd $(TERMCAP_DIR) && \
		CC=$(CC) 					\
		RANLIB=$(RANLIB)			\
		CFLAGS='$(STATIC_FLAG)'		\
		CXXFLAGS='$(STATIC_FLAG)'	\
		./configure 				\
			--disable-shared		\
			--enable-static
	$(Q)touch $@

$(BUILD_DIR)/termcap-patch-makefile-stamp: $(BUILD_DIR)/termcap-configure-stamp
	$(Q)sed -i -e 's|AR = ar|AR = $(AR)|g' $(TERMCAP_DIR)/Makefile

$(TERMCAP_DIR)/libtermcap.a: $(BUILD_DIR)/termcap-patch-makefile-stamp
	$(Q)$(MAKE) -C $(TERMCAP_DIR)

.PHONY: termcap.clean
termcap.clean:
	-$(Q)$(MAKE) -C $(TERMCAP_DIR) clean
	-$(Q)$(RM) $(BUILD_DIR)/termcap-*-stamp $(BUILD_DIR)/termcap-$(TERMCAP_VERSION).tar.gz
	-$(Q)$(RM) -r $(TERMCAP_DIR)


##################################################

# Set the appropriate flags to link with this library.
TERMCAP_CFLAGS :=
TERMCAP_CPPFLAGS := -I$(TERMCAP_DIR)
TERMCAP_CXXFLAGS :=
TERMCAP_LDFLAGS := -L$(TERMCAP_DIR) -ltermcap
