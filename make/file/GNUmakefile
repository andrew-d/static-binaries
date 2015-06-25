include config.mk

FILE_VERSION := 5.23
FILE_DIR := $(BUILD_DIR)/file-$(FILE_VERSION)
FILE_TEMP_DIR := $(BUILD_DIR)/file-$(FILE_VERSION)-temp

.PHONY: file.bin file.install
file.bin: $(FILE_DIR)/file
file.install: $(OUT_DIR)/file-$(PLATFORM)-$(ARCH)
file.ext: $(OUT_DIR)/magic.mgc

FILE_STATIC_FLAG := $(STATIC_FLAG)
ifneq "$(PLATFORM)" "darwin"
	FILE_STATIC_FLAG += -Wl,-static -static-libgcc
endif

##################################################

$(FILE_TEMP_DIR):
	$(Q)mkdir -p $@

# Fetch the source
$(BUILD_DIR)/file-$(FILE_VERSION).tar.gz: | $(BUILD_DIR)
	$(Q)curl -sL -o $@ ftp://ftp.astron.com/pub/file/file-${FILE_VERSION}.tar.gz

# Untar
$(BUILD_DIR)/file-untar-stamp: $(BUILD_DIR)/file-$(FILE_VERSION).tar.gz
	$(Q)tar zxf $< -C $(BUILD_DIR)
	$(Q)touch $@

# Patch.  This:
#   1. Disables tests (which don't work when cross-compiling
#   2. Fixes header files.
$(BUILD_DIR)/file-patch-stamp: $(BUILD_DIR)/file-untar-stamp
	$(Q)printf "all:\n\ttrue\n\ninstall:\n\ttrue\n\n" > $(FILE_DIR)/tests/Makefile.in
	$(Q)sed -i 's/memory.h/string.h/' $(FILE_DIR)/src/encoding.c $(FILE_DIR)/src/ascmagic.c
	$(Q)touch $@

# We need a native build of `file` in order to compile the database for the
# cross build.  This step does that.
$(FILE_TEMP_DIR)/file: $(BUILD_DIR)/file-patch-stamp | $(FILE_TEMP_DIR)
	$(Q)cd $(FILE_DIR) && ./configure --disable-shared
	$(Q)$(MAKE) -C $(FILE_DIR)
	$(Q)mv $(FILE_DIR)/src/file $@
	$(Q)$(MAKE) -C $(FILE_DIR) distclean || true

# Run configure
$(BUILD_DIR)/file-configure-stamp: $(FILE_TEMP_DIR)/file
	$(Q)cd $(FILE_DIR) && \
		CC=$(CC) \
		AR=$(AR) \
		CFLAGS='$(FILE_STATIC_FLAG)' \
		CPPFLAGS='-D_GNU_SOURCE -D_BSD_SOURCE' \
		./configure \
			--disable-shared \
			--host=$(shell $(CC) -dumpmachine | sed 's/musl/gnu/') \
			--build=i686
	$(Q)touch $@

$(FILE_DIR)/src/file: $(BUILD_DIR)/file-configure-stamp $(FILE_TEMP_DIR)/file
	$(Q)PATH=$(FILE_TEMP_DIR):$$PATH $(MAKE) -C $(FILE_DIR)

$(OUT_DIR)/file-$(PLATFORM)-$(ARCH): $(FILE_DIR)/src/file | $(OUT_DIR)
	$(Q)cp $< $@
	$(Q)$(STRIP) $@

$(OUT_DIR)/magic.mgc: $(FILE_DIR)/magic/magic.mgc | $(OUT_DIR)
	$(Q)cp $< $@

.PHONY: file.clean
file.clean:
	-$(Q)$(MAKE) -C $(FILE_DIR) clean
	-$(Q)$(RM) $(BUILD_DIR)/file-*-stamp $(BUILD_DIR)/file-$(FILE_VERSION).tar.gz
	-$(Q)$(RM) -r $(FILE_DIR)
