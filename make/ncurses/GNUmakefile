include config.mk

NCURSES_VERSION := 5.9
NCURSES_DIR := $(BUILD_DIR)/ncurses-$(NCURSES_VERSION)

.PHONY: ncurses.lib
ncurses.lib: $(NCURSES_DIR)/lib/libncurses.a

# Ncurses doesn't recognize the musl ABI, so we use a dummy value and manually
# set the various programs needed.
NCURSES_HOST := $(CROSS_PREFIX)
ifeq "$(PLATFORM)" "linux"
	ifeq "$(ARCH)" "amd64"
		NCURSES_HOST := i686
	endif
else ifeq "$(PLATFORM)" "android"
	NCURSES_HOST := arm-none-linux-gnueabi
endif

##################################################

# Fetch the source
$(BUILD_DIR)/ncurses-$(NCURSES_VERSION).tar.gz: | $(BUILD_DIR)
	$(Q)curl -sL -o $@ http://invisible-island.net/datafiles/release/ncurses.tar.gz

# Untar
$(BUILD_DIR)/ncurses-untar-stamp: $(BUILD_DIR)/ncurses-$(NCURSES_VERSION).tar.gz
	$(Q)tar zxf $< -C $(BUILD_DIR)
	$(Q)touch $@

# Patch
$(BUILD_DIR)/ncurses-patch-stamp: $(BUILD_DIR)/ncurses-untar-stamp
	$(Q)cd $(NCURSES_DIR) && \
		if test -n "$$(find $(ncurses) -maxdepth 1 -name '$(PLATFORM)-*.patch' -print -quit)"; then \
			for fname in $(ncurses)/$(PLATFORM)-*.patch;	\
			do 												\
				patch -p1 < $$fname ; 						\
			done											\
		fi
	$(Q)touch $@

# Run configure
$(BUILD_DIR)/ncurses-configure-stamp: $(BUILD_DIR)/ncurses-patch-stamp
	$(Q)cd $(NCURSES_DIR) && \
		CC=$(CC)					\
		CXX=$(CXX)					\
		AR=$(AR)					\
		RANLIB=$(RANLIB)			\
		CFLAGS='$(STATIC_FLAG)'		\
		CXXFLAGS='$(STATIC_FLAG)'	\
		./configure 				\
			--disable-shared		\
			--enable-static			\
			--with-normal 			\
			--without-debug 		\
			--without-ada			\
			--host=$(NCURSES_HOST)  \
			--build=i686
	$(Q)touch $@

$(NCURSES_DIR)/lib/libncurses.a: $(BUILD_DIR)/ncurses-configure-stamp
	$(Q)$(MAKE) -C $(NCURSES_DIR)

.PHONY: ncurses.clean
ncurses.clean:
	-$(Q)$(MAKE) -C $(NCURSES_DIR) clean
	-$(Q)$(RM) $(BUILD_DIR)/ncurses-*-stamp $(BUILD_DIR)/ncurses-$(NCURSES_VERSION).tar.gz
	-$(Q)$(RM) -r $(NCURSES_DIR)


##################################################

# Set the appropriate flags to link with this library.
NCURSES_CFLAGS :=
NCURSES_CPPFLAGS := -I$(NCURSES_DIR)
NCURSES_CXXFLAGS :=
NCURSES_LDFLAGS := -L$(NCURSES_DIR)/lib -lncurses
