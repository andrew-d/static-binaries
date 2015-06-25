# Always use bash, not whatever is installed as /bin/sh
SHELL := /bin/bash

# Disable built-in suffix rules.
.SUFFIXES:

# Turn off the RCS / SCCS implicit rules of GNU Make
% : RCS/%,v
% : RCS/%
% : %,v
% : s.%
% : SCCS/s.%

# If a rule fails, delete $@.
.DELETE_ON_ERROR:

# Check for broken versions of make.
# (Allow any version under Cygwin since we don't actually build the platform there.)
ifneq (1,$(strip $(shell expr $(MAKE_VERSION) \>= 3.81)))
$(warning ********************************************************************************)
$(warning *  You are using version $(MAKE_VERSION) of make.)
$(warning *  Android can only be built by versions 3.81 and higher.)
$(warning *  see https://source.android.com/source/download.html)
$(warning ********************************************************************************)
$(error stopping)
endif

# Absolute path of the present working direcotry.
# This overrides the shell variable $PWD, which does not necessarily point to
# the top of the source tree, for example when "make -C" is used.
PWD := $(shell pwd)

TOP := .
TOPDIR :=

# This is the default target.  It must be the first declared target.
.PHONY: all
DEFAULT_GOAL := all
$(DEFAULT_GOAL):

# The path to the directory containing our build system's Makefiles.
BUILD_SYSTEM := $(TOPDIR)build

# Set up standard variables based on configuration.
include $(BUILD_SYSTEM)/config.mk

# Check the sanity of the build tools.
VERSION_CHECK_SEQUENCE_NUMBER := 5
-include $(OUT_DIR)/versions_checked.mk
ifneq ($(VERSION_CHECK_SEQUENCE_NUMBER),$(VERSIONS_CHECKED))

$(info Checking build tools versions...)

# Make sure that there are no spaces in the absolute path; the
# build system can't deal with them.
ifneq ($(words $(shell pwd)),1)
$(warning ************************************************************)
$(warning You are building in a directory whose absolute path contains)
$(warning a space character:)
$(warning $(space))
$(warning "$(shell pwd)")
$(warning $(space))
$(warning Please move your source tree to a path that does not contain)
$(warning any spaces.)
$(warning ************************************************************)
$(error Directory names containing spaces not supported)
endif

# Now that we've checked all our build tools, write the include file that we
# load next time.
$(shell echo 'VERSIONS_CHECKED := $(VERSION_CHECK_SEQUENCE_NUMBER)' \
        > $(OUT_DIR)/versions_checked.mk)
endif

# Bring in standard build system definitions
include $(BUILD_SYSTEM)/definitions.mk
