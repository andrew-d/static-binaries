Q       ?= @
ROOT    := $(abspath .)
OUT_DIR := $(ROOT)/binaries2

all:
	@echo "TODO: should we build everything?"

$(OUT_DIR):
	$(Q)mkdir -p $@

# TODO:
#   1. Use $(eval) to reduce duplication

.PHONY: linux-amd64
linux-amd64: | $(OUT_DIR)
	$(Q)docker run \
		--rm \
		-v $(ROOT)/make:/make \
		-v $(OUT_DIR):/output \
		andrewd/musl-cross \
		/bin/bash \
			-c "cd /make && make PLATFORM=linux ARCH=amd64 Q=$(Q) install"

.PHONY: android
android: | $(OUT_DIR)
	$(Q)docker run \
		--rm \
		-v $(ROOT)/make:/make \
		-v $(OUT_DIR):/output \
		andrewd/musl-cross-arm \
		/bin/bash \
			-c "cd /make && make PLATFORM=android Q=$(Q) install"


.PHONY: darwin-amd64
darwin-amd64: | $(OUT_DIR)
	$(Q)docker run \
		--rm \
		-v $(ROOT)/make:/make \
		-v $(OUT_DIR):/output \
		andrewd/osxcross \
		/bin/bash \
			-c "cd /make && make PLATFORM=darwin ARCH=amd64 Q=$(Q) install"
