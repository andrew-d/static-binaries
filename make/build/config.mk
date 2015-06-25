# This file is included by the top-level Makefile.  It sets up
# standard variables based on the current configuration and
# platform that are not specific to what is being built.

# Always use bash, not whatever is installed as /bin/sh
SHELL := /bin/bash

# Utility variables

empty :=
space := $(empty) $(empty)
comma := ,

# Note: make removes the newline immediately prior to `endef`
define newline


endef

backslash := \a
backslash := $(patsubst %a,%,$(backslash))


# ###############################################################
# Build system internal files
# ###############################################################

BUILD_COMBOS:= $(BUILD_SYSTEM)/combo

CLEAR_VARS:= $(BUILD_SYSTEM)/clear_vars.mk
# TODO: BUILD_STATIC_LIBRARY := $(BUILD_SYSTEM)/static_library.mk
# TODO: BUILD_HOST_EXECUTABLE := $(BUILD_SYSTEM)/host_executable.mk
# TODO: BUILD_TARGET_EXECUTABLE := $(BUILD_SYSTEM)/target_executable.mk


# ###############################################################
# Include sub-configuration files
# ###############################################################

# This sets up most of the global variables that are specific to the
# user's build configuration.
include $(BUILD_SYSTEM)/envsetup.mk

# ###############################################################
# Generic tools
# ###############################################################

COLUMN := column

# It's called md5 on Mac OS and md5sum on Linux
ifeq ($(HOST_OS),darwin)
MD5SUM:=md5 -q
else
MD5SUM:=md5sum
endif
