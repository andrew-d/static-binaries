Q       ?= @
SHELL   := /bin/bash
ROOT    := $(abspath .)
OUT_DIR := $(ROOT)/binaries2

all:
	@echo "TODO: should we build everything?"

$(OUT_DIR):
	$(Q)mkdir -p $@

# Helper rule to run a Docker image to perform a given build.
define DOCKER_RUN
.PHONY: $1-$2
$1-$2: | $$(OUT_DIR)
	$$(Q)./run-docker.sh $1 $2 $3 $$(OUT_DIR) @
endef

$(eval $(call DOCKER_RUN,linux,amd64,andrewd/musl-cross))
$(eval $(call DOCKER_RUN,android,arm,andrewd/musl-cross-arm))
$(eval $(call DOCKER_RUN,darwin,amd64,andrewd/osxcross))

.PHONY: clean
clean:
	$(Q)$(RM) -r $(OUT_DIR)
