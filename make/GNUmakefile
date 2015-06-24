include config.mk

src  	 ?= $(abspath .)
file     := $(src)/file
lzma     := $(src)/lzma
ncurses  := $(src)/ncurses
openssl  := $(src)/openssl
pcre     := $(src)/pcre
readline := $(src)/readline
socat    := $(src)/socat
termcap  := $(src)/termcap
zlib     := $(src)/zlib


.PHONY: all
all:
	@echo "Cannot make all - please build a specific target"

$(BUILD_DIR):
	$(Q)mkdir -p $@

$(OUT_DIR):
	$(Q)mkdir -p $@


# Include libraries
include $(lzma)/GNUmakefile
include $(ncurses)/GNUmakefile
include $(openssl)/GNUmakefile
include $(pcre)/GNUmakefile
include $(readline)/GNUmakefile
include $(termcap)/GNUmakefile
include $(zlib)/GNUmakefile

# Include program definitions
include $(file)/GNUmakefile
include $(socat)/GNUmakefile

# Final targets that contain all binaries / installs
.PHONY: bin install
install: file.install file.ext socat.install
	@echo "***** Install Finished *****"

bin: file.bin socat.bin
	@echo "***** Build Finished *****"
