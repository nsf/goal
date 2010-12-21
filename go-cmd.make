#------------------------------------------------------------------------------
# TEMPLATE_GO_COMMAND
#-IN---------------------------------------------------------------------------
# curdir     - current directory in a form of a prefix (can be empty)
# targ       - target name
# gcflags    - package local GC compiler flags
# glflags    - package local GC linker flags
# cmddir     - installation destination in a form of a prefix (defaults to $(GOBIN))
#-------
# FILES: (all files should be relative to $(curdir))
#-------
# cleanfiles - additional list of files for removing during clean
# gofiles    - list of the go source files (prefixed with $(curdir))
#-OUT--------------------------------------------------------------------------
# creates a bunch of targets:
#   $(curdir)$(targ)
#   $(curdir)$(targ)/all
#   $(curdir)$(targ)/install
#   $(curdir)$(targ)/clean
#------------------------------------------------------------------------------
define TEMPLATE_GO_COMMAND
$(eval gofiles    := $(addprefix $(curdir),$(gofiles)))
$(eval cleanfiles := $(addprefix $(curdir),$(cleanfiles)))
$(eval curdirI    := $(call DIR_AS_I_FLAG,$(curdir)))
$(eval curdirL    := $(call DIR_AS_L_FLAG,$(curdir)))
$(eval cmddir     := $(if $(cmddir),$(cmddir),$(call DIR_AS_PREFIX,$(GOBIN))))

$(curdir)$(targ)/all: $(curdir)$(targ)

$(curdir)$(targ): $(curdir)_go_.$O
	$(LD)$(call PRESPACE,$(curdirL))$(call PRESPACE,$(glflags)) -o $$@ $(curdir)_go_.$O

$(curdir)_go_.$O: $(gofiles)
	$(GC)$(call PRESPACE,$(curdirI))$(call PRESPACE,$(gcflags)) -o $$@ $(gofiles)

$(cmddir)$(targ): $(curdir)$(targ)
	cp -f $(curdir)$(targ) $(cmddir)

$(curdir)$(targ)/install: $(cmddir)$(targ)

$(curdir)$(targ)/clean:
	rm -rf $(curdir)*.o $(curdir)*.a $(curdir)*.[$(OS)]\
		$(curdir)[$(OS)].out $(curdir)$(targ) $(cleanfiles)

.PHONY: $(curdir)$(targ)/all\
	$(curdir)$(targ)/clean\
	$(curdir)$(targ)/install

# target local variables
$(curdir)$(targ)/all $(curdir)$(targ)/clean $(curdir)$(targ)/install: curdir       := $(curdir)
$(curdir)$(targ)/all $(curdir)$(targ)/clean $(curdir)$(targ)/install: targ         := $(targ)
$(curdir)$(targ)/all $(curdir)$(targ)/clean $(curdir)$(targ)/install: gofiles      := $(gofiles)
$(curdir)$(targ)/all $(curdir)$(targ)/clean $(curdir)$(targ)/install: gcflags      := $(gcflags)
$(curdir)$(targ)/all $(curdir)$(targ)/clean $(curdir)$(targ)/install: glflags      := $(glflags)
$(curdir)$(targ)/all $(curdir)$(targ)/clean $(curdir)$(targ)/install: cmddir       := $(pkgdir)
$(curdir)$(targ)/all $(curdir)$(targ)/clean $(curdir)$(targ)/install: cleanfiles   := $(cleanfiles)

endef
#------------------------------------------------------------------------------
# TEMPLATE_GO_COMMAND_CLEAN_VARS
#------------------------------------------------------------------------------
# Template that cleans vars for TEMPLATE_GO_COMMAND.
#------------------------------------------------------------------------------
define TEMPLATE_GO_COMMAND_CLEAN_VARS

curdir       := 
targ         := 
gofiles      := 
gcflags      := 
glflags      :=
cmddir       := 
cleanfiles   := 

endef

#------------------------------------------------------------------------------
# TEMPLATE_GO_COMMAND_IN_DIR
#-ARGS-------------------------------------------------------------------------
# $1 - directory of a command
#------------------------------------------------------------------------------
define TEMPLATE_GO_COMMAND_IN_DIR

$(eval $(TEMPLATE_GO_COMMAND_CLEAN_VARS))
$(eval curdir := $(call DIR_AS_PREFIX,$1))
$(eval include $(curdir)Make.def)
$(eval $(TEMPLATE_GO_COMMAND))

endef

# vim: ft=make
