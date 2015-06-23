ifndef CONFIG_MK
CONFIG_MK := 1 # Prevent repeated "-include".

# Use bash as a shell, always.
SHELL := /bin/bash

# Disable built-in suffix rules.
.SUFFIXES:

# Default Darwin version supported
DARWIN_VERSION := 12

# Validate that we were provided appropriate platform and architecture values.
ifeq "$(PLATFORM)" "linux"
	ifeq "$(ARCH)" "x86"
		CROSS_PREFIX := $(error Currently, static x86 is not supported)
	else ifeq "$(ARCH)" "amd64"
		CROSS_PREFIX := x86_64-linux-musl
	else
		CROSS_PREFIX := $(error No valid architecture provided: $(ARCH))
	endif
else ifeq "$(PLATFORM)" "android"
	CROSS_PREFIX := arm-linux-musleabihf
else ifeq "$(PLATFORM)" "darwin"
	CROSS_PREFIX := x86_64-apple-darwin$(DARWIN_VERSION)
else ifeq "$(PLATFORM)" "windows"
	CROSS_PREFIX := $(error Currently, cross-compiling to Windows is not supported)
else
	CROSS_PREFIX := $(error No valid platform provided: $(PLATFORM))
endif


# Configuration
BUILD_DIR := /build
OUT_DIR   := /output/$(PLATFORM)
ifdef $(ARCH)
	OUT_DIR := $(OUT_DIR)/$(ARCH)
endif

# Compiler configuration
AR           := $(CROSS_PREFIX)-ar
CC           := $(CROSS_PREFIX)-gcc
CXX          := $(CROSS_PREFIX)-g++
LD           := $(CROSS_PREFIX)-ld
RANLIB       := $(CROSS_PREFIX)-ranlib
STRIP        := $(CROSS_PREFIX)-strip

# Special override for Darwin/osxcross - use clang
ifeq "$(PLATFORM)" "darwin"
	CC  := $(CROSS_PREFIX)-clang
	CXX := $(CROSS_PREFIX)-clang++

	# Disable irritating warning.
	export OSXCROSS_NO_INCLUDE_PATH_WARNINGS := 1
endif

# Flag for compiling statically - not true on Darwin
ifeq "$(PLATFORM)" "darwin"
	STATIC_FLAG := -flto -O3 -mmacosx-version-min=10.6
else
	STATIC_FLAG := -static
endif

# Allow showing commands
Q ?= @

# Helper rule to print variables.
%. :
	@echo '$($*)'

endif
