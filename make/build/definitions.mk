# Common build system definitions.  Mostly helpful shortcuts or
# functions, since we don't actually compile code here.

# The names of all packages in the system.
ALL_PACKAGES :=


###########################################################
## Debugging; prints a variable list to stdout
###########################################################

# $(1): variable name list, not variable values
define print-vars
$(foreach var,$(1), \
  $(info $(var):) \
  $(foreach word,$($(var)), \
    $(info $(space)$(space)$(word)) \
   ) \
 )
endef


###########################################################
## Retrieve the directory of the current makefile
## Must be called before including any other makefile!!
###########################################################

# Figure out where we are.
define my-dir
$(strip \
  $(eval LOCAL_MODULE_MAKEFILE := $$(lastword $$(MAKEFILE_LIST))) \
  $(if $(filter $(BUILD_SYSTEM)/% $(OUT_DIR)/%,$(LOCAL_MODULE_MAKEFILE)), \
    $(error my-dir must be called before including any other makefile.) \
   , \
    $(patsubst %/,%,$(dir $(LOCAL_MODULE_MAKEFILE))) \
   ) \
 )
endef


###########################################################
## Function we can evaluate to introduce a dynamic dependency
###########################################################

define add-dependency
$(1): $(2)
endef


###########################################################
## Run rot13 on a string
## $(1): the string.  Must be one line.
###########################################################

define rot13
$(shell echo $(1) | tr 'a-zA-Z' 'n-za-mN-ZA-M')
endef


###########################################################
## Returns true if $(1) and $(2) are equal.  Returns
## the empty string if they are not equal.
###########################################################

define streq
$(strip $(if $(strip $(1)),\
  $(if $(strip $(2)),\
    $(if $(filter-out __,_$(subst $(strip $(1)),,$(strip $(2)))$(subst $(strip $(2)),,$(strip $(1)))_),,true), \
    ),\
  $(if $(strip $(2)),\
    ,\
    true)\
 ))
endef

###########################################################
## Returns true if $(1) ends with $(2).  Returns the empty
## string if they are not equal.
###########################################################

define strendswith
$(strip $(shell [[ "$(1)" == *$(2) ]] && echo true))
endef



###########################################################
## TODO: Command for running 'make' to build an output
## TODO: Command for running ./configure to prepare a build
###########################################################
