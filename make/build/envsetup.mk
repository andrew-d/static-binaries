# ---------------------------------------------------------------
# Set up configuration for the host machine.
UNAME := $(shell uname -sm)

ifneq (,$(findstring Linux,$(UNAME)))
  HOST_OS := linux
endif
ifneq (,$(findstring Darwin,$(UNAME)))
  HOST_OS := darwin
endif
ifneq (,$(findstring Macintosh,$(UNAME)))
  HOST_OS := darwin
endif
ifneq (,$(findstring CYGWIN,$(UNAME)))
  HOST_OS := windows
endif

ifeq ($(HOST_OS),)
$(error Unable to determine HOST_OS from uname -sm: $(UNAME)!)
endif

ifneq (,$(findstring x86_64,$(UNAME)))
  HOST_ARCH := x86_64
else
ifneq (,$(findstring x86,$(UNAME)))
$(error Building on a 32-bit x86 host is not supported: $(UNAME)!)
endif
endif

ifeq ($(HOST_ARCH),)
$(error Unable to determine HOST_ARCH from uname -sm: $(UNAME)!)
endif


# ---------------------------------------------------------------
# Figure out the output directory
ifeq (,$(strip $(OUT_DIR)))
OUT_DIR := $(TOPDIR)out
endif


# ---------------------------------------------------------------
# TODO: figure out the target output dir, etc...
