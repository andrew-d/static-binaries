include config.mk

READLINE_VERSION := 6.3
READLINE_DIR := $(BUILD_DIR)/readline-$(READLINE_VERSION)

.PHONY: readline.lib readline.symlink
readline.lib: $(READLINE_DIR)/libreadline.a readline.symlink
readline.symlink: $(READLINE_DIR)/readline

##################################################

# Fetch the source
$(BUILD_DIR)/readline-$(READLINE_VERSION).tar.gz: | $(BUILD_DIR)
	$(Q)curl -sL -o $@ ftp://ftp.cwru.edu/pub/bash/readline-$(READLINE_VERSION).tar.gz

# Untar
$(BUILD_DIR)/readline-untar-stamp: $(BUILD_DIR)/readline-$(READLINE_VERSION).tar.gz
	$(Q)tar zxf $< -C $(BUILD_DIR)
	$(Q)touch $@

# Prevent building examples (which can't be done when cross-compiling)
$(BUILD_DIR)/readline-patch-stamp: $(BUILD_DIR)/readline-untar-stamp
	$(Q)sed -i -e 's|examples/Makefile||g' $(READLINE_DIR)/configure.ac
	$(Q)cd $(READLINE_DIR) && autoconf
	$(Q)touch $@

# Run configure
$(BUILD_DIR)/readline-configure-stamp: $(BUILD_DIR)/readline-patch-stamp
	$(Q)cd $(READLINE_DIR) && \
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

$(READLINE_DIR)/libreadline.a: $(BUILD_DIR)/readline-configure-stamp
	$(Q)$(MAKE) -C $(READLINE_DIR)

# Dummy symlink, so things that include <readline/readline.h> work.
$(READLINE_DIR)/readline: $(BUILD_DIR)/readline-untar-stamp
	$(Q)ln -s $(READLINE_DIR) $@

.PHONY: readline.clean
readline.clean:
	-$(Q)$(MAKE) -C $(READLINE_DIR) clean
	-$(Q)$(RM) $(BUILD_DIR)/readline-*-stamp $(BUILD_DIR)/readline-$(READLINE_VERSION).tar.gz
	-$(Q)$(RM) -r $(READLINE_DIR)


##################################################

# Set the appropriate flags to link with this library.
READLINE_CFLAGS :=
READLINE_CPPFLAGS := -I$(READLINE_DIR)
READLINE_CXXFLAGS :=
READLINE_LDFLAGS := -L$(READLINE_DIR) -lreadline
