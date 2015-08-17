# ---------------------------------------------------------------
# Sanity checks

ifeq ($(LOCAL_NAME),)
	$(error No name provided)
endif

ifeq ($(LOCAL_VERSION),)
	$(error No version provided for: $(LOCAL_NAME))
endif

ifeq ($(LOCAL_SOURCE),)
	$(error No source URL was provided for: $(LOCAL_NAME))
endif

# ---------------------------------------------------------------
# Set up output files

my_build_dir := $(OUT_DIR)/$(LOCAL_NAME)

# Try and discover the archive format from the source URL.
ifeq ($(LOCAL_SOURCE_FORMAT),)
my_source_name := $(shell basename "$(LOCAL_SOURCE)")

ifeq ($(eval $(call strendswith,$(LOCAL_SOURCE_FORMAT),.tar.gz)),true)
	LOCAL_SOURCE_FORMAT := tar.gz
endif
ifeq ($(eval $(call strendswith,$(LOCAL_SOURCE_FORMAT),.tar.bz2)),true)
	LOCAL_SOURCE_FORMAT := tar.bz2
endif
ifeq ($(eval $(call strendswith,$(LOCAL_SOURCE_FORMAT),.tar.xz)),true)
	LOCAL_SOURCE_FORMAT := tar.xz
endif
ifeq ($(eval $(call strendswith,$(LOCAL_SOURCE_FORMAT),.zip)),true)
	LOCAL_SOURCE_FORMAT := zip
endif
ifeq ($(eval $(call strendswith,$(LOCAL_SOURCE_FORMAT),.git)),true)
	LOCAL_SOURCE_FORMAT := git

# We also have some additional options!
ifeq ($(LOCAL_GIT_BRANCH),)
	LOCAL_GIT_BRANCH := master
endif

endif
endif

# Generate an output file name for the source URL.
my_file_name := $(LOCAL_NAME)-$(LOCAL_VERSION).$(LOCAL_SOURCE_FORMAT)
my_fetched_file := $(my_build_dir)/$(my_file_name)

# Allow overriding the name inside the archive.
ifeq ($(LOCAL_EXTRACTED_NAME),)
my_dir_name := $(LOCAL_NAME)-$(LOCAL_VERSION)
else
my_dir_name := $(LOCAL_EXTRACTED_NAME)
endif

# Determine what program we use to fetch and extract the downloaded file.  We
# define a command that takes the input file as $(1) and extracts it inside
# the directory given in $(2).
fetch_command   := curl -sL -o $(my_build_dir)/$(my_file_name) $(LOCAL_SOURCE)
extract_command := $(error Unknown source format for: $(LOCAL_NAME))

ifeq ($(LOCAL_SOURCE_FORMAT),tar.gz)
#fetch_command := <default>
extract_command := tar -C $(my_build_dir) xzf $(my_fetched_file)
endif
ifeq ($(LOCAL_SOURCE_FORMAT),tar.bz2)
#fetch_command := <default>
extract_command := tar -C $(my_build_dir) xJf $(my_fetched_file)
endif
ifeq ($(LOCAL_SOURCE_FORMAT),tar.xz)
#fetch_command := <default>
extract_command := xz -dc $(my_fetched_file) | tar -C $(2) xf -
endif
ifeq ($(LOCAL_SOURCE_FORMAT),zip)
#fetch_command := <default>
extract_command := unzip -d $(my_build_dir) $(my_fetched_file)
endif
ifeq ($(LOCAL_SOURCE_FORMAT),git)
fetch_command := cd $(my_build_dir) && git clone -b $(LOCAL_GIT_BRANCH) $(LOCAL_SOURCE) $(my_dir_name)
extract_command := true
endif

# ---------------------------------------------------------------
# Define Makefile rules

$(my_build_dir):
	$(Q)mkdir -p $@

# Fetch source
$(my_build_dir)/$(my_file_name): | $(my_build_dir)
	$(Q)$(call fetch_command)

# Unpack
$(my_build_dir)/stamp-unpack: | $(my_build_dir)
	$(Q)$(call extract_command)
	$(Q)[[ ! -d "$(my_build_dir)/$(my_dir_name)" ]] && ( echo "Extract command did not create the expected directory: $(my_build_dir)/$(my_dir_name) - consider setting the LOCAL_EXTRACTED_NAME variable" ; exit 1)
	$(Q)touch $@

# Run configure
# TODO
