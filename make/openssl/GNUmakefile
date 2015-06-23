include config.mk

OPENSSL_VERSION := 1.0.2c
OPENSSL_DIR := $(BUILD_DIR)/openssl-$(OPENSSL_VERSION)

.PHONY: openssl.lib
openssl.lib: $(OPENSSL_DIR)/libcrypto.a $(OPENSSL_DIR)/libssl.a

# Need to set the appropriate configure target
OPENSSL_TARGET := invalid
ifeq "$(PLATFORM)" "linux"
	ifeq "$(ARCH)" "amd64"
		OPENSSL_TARGET := linux-x86_64
	else
		OPENSSL_TARGET := $(error Cannot build OpenSSL for architecture $(ARCH))
	endif
else ifeq "$(PLATFORM)" "android"
	OPENSSL_TARGET := android-armv7
else ifeq "$(PLATFORM)" "darwin"
	ifeq "$(ARCH)" "amd64"
		OPENSSL_TARGET := darwin64-x86_64-cc enable-ec_nistp_64_gcc_128
	else ifeq "$(ARCH)" "x86"
		OPENSSL_TARGET := darwin-i386-cc
	else
		OPENSSL_TARGET := $(error Cannot build OpenSSL for architecture $(ARCH))
	endif
else
	OPENSSL_TARGET := $(error Cannot build OpenSSL for platform $(PLATFORM))
endif

##################################################

# Fetch the source
$(BUILD_DIR)/openssl-$(OPENSSL_VERSION).tar.gz: | $(BUILD_DIR)
	$(Q)curl -sL -o $@ https://www.openssl.org/source/openssl-$(OPENSSL_VERSION).tar.gz

# Untar
$(BUILD_DIR)/openssl-untar-stamp: $(BUILD_DIR)/openssl-$(OPENSSL_VERSION).tar.gz
	$(Q)tar zxf $< -C $(BUILD_DIR)
	$(Q)touch $@

# Run configure
$(BUILD_DIR)/openssl-configure-stamp: $(BUILD_DIR)/openssl-untar-stamp
	$(Q)cd $(OPENSSL_DIR) && \
		CC=$(CC)					\
		CXX=$(CXX)					\
		AR=$(AR)					\
		RANLIB=$(RANLIB)			\
		CFLAGS='$(STATIC_FLAG)'		\
		CXXFLAGS='$(STATIC_FLAG)'	\
		./Configure 				\
		no-shared 					\
		$(OPENSSL_TARGET)
	$(Q)touch $@

$(OPENSSL_DIR)/libcrypto.a $(OPENSSL_DIR)/libssl.a: $(BUILD_DIR)/openssl-configure-stamp
	$(Q)$(MAKE) -C $(OPENSSL_DIR) build_libs

.PHONY: openssl.clean
openssl.clean:
	-$(Q)$(MAKE) -C $(OPENSSL_DIR) clean
	-$(Q)$(RM) $(BUILD_DIR)/openssl-*-stamp $(BUILD_DIR)/openssl-$(OPENSSL_VERSION).tar.gz
	-$(Q)$(RM) -r $(OPENSSL_DIR)


##################################################

# Set the appropriate flags to link with this library.
OPENSSL_CFLAGS :=
OPENSSL_CPPFLAGS := -I$(OPENSSL_DIR)/include
OPENSSL_CXXFLAGS :=
OPENSSL_LDFLAGS := -L$(OPENSSL_DIR)
